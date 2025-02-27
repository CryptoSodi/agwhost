// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package org.starling.core
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import org.adobe.utils.AGALMiniAssembler;
	import org.starling.display.BlendMode;
	import org.starling.display.DisplayObject;
	import org.starling.display.Quad;
	import org.starling.display.QuadBatch;
	import org.starling.errors.MissingContextError;
	import org.starling.textures.Texture;
	import org.starling.utils.Color;
	import org.starling.utils.MatrixUtil;
	import org.starling.utils.RectangleUtil;

	/** A class that contains helper methods simplifying Stage3D rendering.
	 *
	 *  A RenderSupport instance is passed to any "render" method of display objects.
	 *  It allows manipulation of the current transformation matrix (similar to the matrix
	 *  manipulation methods of OpenGL 1.x) and other helper methods.
	 */
	public class RenderSupport
	{
		// members

		private var mProjectionMatrix:Matrix;
		private var mModelViewMatrix:Matrix;
		private var mMvpMatrix:Matrix;
		private var mMvpMatrix3D:Matrix3D;
		private var mMatrixStack:Vector.<Matrix>;
		private var mMatrixStackSize:int;

		private var mDrawCount:int;
		private var mBlendMode:String;

		private var mRenderTarget:Texture;
		private var mBackBufferWidth:int;
		private var mBackBufferHeight:int;

		private var mClipRectStack:Vector.<Rectangle>;
		private var mClipRectStackSize:int;

		private var mQuadBatches:Vector.<QuadBatch>;
		private var mCurrentQuadBatchID:int;

		/** helper objects */
		private static var sPoint:Point                 = new Point();
		private static var sRectangle:Rectangle         = new Rectangle();
		private static var sAssembler:AGALMiniAssembler = new AGALMiniAssembler();

		// construction

		/** Creates a new RenderSupport object with an empty matrix stack. */
		public function RenderSupport()
		{
			mProjectionMatrix = new Matrix();
			mModelViewMatrix = new Matrix();
			mMvpMatrix = new Matrix();
			mMvpMatrix3D = new Matrix3D();
			mMatrixStack = new <Matrix>[];
			mMatrixStackSize = 0;
			mDrawCount = 0;
			mRenderTarget = null;
			mBlendMode = BlendMode.NORMAL;
			mClipRectStack = new <Rectangle>[];

			mCurrentQuadBatchID = 0;
			mQuadBatches = new <QuadBatch>[new QuadBatch()];

			loadIdentity();
			setOrthographicProjection(0, 0, 400, 300);
		}

		/** Disposes all quad batches. */
		public function dispose():void
		{
			for each (var quadBatch:QuadBatch in mQuadBatches)
				quadBatch.dispose();
		}

		// matrix manipulation

		/** Sets up the projection matrix for ortographic 2D rendering. */
		public function setOrthographicProjection( x:Number, y:Number, width:Number, height:Number ):void
		{
			mProjectionMatrix.setTo(2.0 / width, 0, 0, -2.0 / height,
									-(2 * x + width) / width, (2 * y + height) / height);

			applyClipRect();
		}

		/** Changes the modelview matrix to the identity matrix. */
		public function loadIdentity():void
		{
			mModelViewMatrix.identity();
		}

		/** Prepends a translation to the modelview matrix. */
		public function translateMatrix( dx:Number, dy:Number ):void
		{
			MatrixUtil.prependTranslation(mModelViewMatrix, dx, dy);
		}

		/** Prepends a rotation (angle in radians) to the modelview matrix. */
		public function rotateMatrix( angle:Number ):void
		{
			MatrixUtil.prependRotation(mModelViewMatrix, angle);
		}

		/** Prepends an incremental scale change to the modelview matrix. */
		public function scaleMatrix( sx:Number, sy:Number ):void
		{
			MatrixUtil.prependScale(mModelViewMatrix, sx, sy);
		}

		/** Prepends a matrix to the modelview matrix by multiplying it with another matrix. */
		public function prependMatrix( matrix:Matrix ):void
		{
			MatrixUtil.prependMatrix(mModelViewMatrix, matrix);
		}

		/** Prepends translation, scale and rotation of an object to the modelview matrix. */
		public function transformMatrix( object:DisplayObject ):void
		{
			MatrixUtil.prependMatrix(mModelViewMatrix, object.transformationMatrix);
		}

		/** Pushes the current modelview matrix to a stack from which it can be restored later. */
		public function pushMatrix():void
		{
			if (mMatrixStack.length < mMatrixStackSize + 1)
				mMatrixStack.push(new Matrix());

			mMatrixStack[int(mMatrixStackSize++)].copyFrom(mModelViewMatrix);
		}

		/** Restores the modelview matrix that was last pushed to the stack. */
		public function popMatrix():void
		{
			mModelViewMatrix.copyFrom(mMatrixStack[int(--mMatrixStackSize)]);
		}

		/** Empties the matrix stack, resets the modelview matrix to the identity matrix. */
		public function resetMatrix():void
		{
			mMatrixStackSize = 0;
			loadIdentity();
		}

		/** Prepends translation, scale and rotation of an object to a custom matrix. */
		public static function transformMatrixForObject( matrix:Matrix, object:DisplayObject ):void
		{
			MatrixUtil.prependMatrix(matrix, object.transformationMatrix);
		}

		/** Calculates the product of modelview and projection matrix.
		 *  CAUTION: Use with care! Each call returns the same instance. */
		public function get mvpMatrix():Matrix
		{
			mMvpMatrix.copyFrom(mModelViewMatrix);
			mMvpMatrix.concat(mProjectionMatrix);
			return mMvpMatrix;
		}

		/** Calculates the product of modelview and projection matrix and saves it in a 3D matrix.
		 *  CAUTION: Use with care! Each call returns the same instance. */
		public function get mvpMatrix3D():Matrix3D
		{
			return MatrixUtil.convertTo3D(mvpMatrix, mMvpMatrix3D);
		}

		/** Returns the current modelview matrix.
		 *  CAUTION: Use with care! Each call returns the same instance. */
		public function get modelViewMatrix():Matrix  { return mModelViewMatrix; }

		/** Returns the current projection matrix.
		 *  CAUTION: Use with care! Each call returns the same instance. */
		public function get projectionMatrix():Matrix  { return mProjectionMatrix; }
		public function set projectionMatrix( value:Matrix ):void
		{
			mProjectionMatrix.copyFrom(value);
			applyClipRect();
		}

		// blending

		/** Activates the current blend mode on the active rendering context. */
		public function applyBlendMode( premultipliedAlpha:Boolean ):void
		{
			setBlendFactors(premultipliedAlpha, mBlendMode);
		}

		/** The blend mode to be used on rendering. To apply the factor, you have to manually call
		 *  'applyBlendMode' (because the actual blend factors depend on the PMA mode). */
		public function get blendMode():String  { return mBlendMode; }
		public function set blendMode( value:String ):void
		{
			if (value != BlendMode.AUTO)
				mBlendMode = value;
		}

		// render targets

		/** The texture that is currently being rendered into, or 'null' to render into the
		 *  back buffer. If you set a new target, it is immediately activated. */
		public function get renderTarget():Texture  { return mRenderTarget; }
		public function set renderTarget( target:Texture ):void
		{
			mRenderTarget = target;
			applyClipRect();

			if (target)
				Starling.context.setRenderToTexture(target.base);
			else
				Starling.context.setRenderToBackBuffer();
		}

		/** Configures the back buffer on the current context3D. By using this method, Starling
		 *  can store the size of the back buffer and utilize this information in other methods
		 *  (e.g. the 'clipRect' property). Back buffer width and height can later be accessed
		 *  using the properties with the same name. */
		public function configureBackBuffer( width:int, height:int, antiAlias:int,
											 enableDepthAndStencil:Boolean,
											 wantsBestResolution:Boolean = false ):void
		{
			mBackBufferWidth = width;
			mBackBufferHeight = height;

			var configureBackBuffer:Function = Starling.context.configureBackBuffer;
			var methodArgs:Array             = [width, height, antiAlias, enableDepthAndStencil];
			if (configureBackBuffer.length > 4)
				methodArgs.push(wantsBestResolution);
			try
			{
				configureBackBuffer.apply(Starling.context, methodArgs);
			} catch ( e:Error )
			{
				trace("resize error");
			}
		}

		/** The width of the back buffer, as it was configured in the last call to
		 *  'RenderSupport.configureBackBuffer()'. Beware: changing this value does not actually
		 *  resize the back buffer; the setter should only be used to inform Starling about the
		 *  size of a back buffer it can't control (shared context situations).
		 */
		public function get backBufferWidth():int  { return mBackBufferWidth; }
		public function set backBufferWidth( value:int ):void  { mBackBufferWidth = value; }

		/** The height of the back buffer, as it was configured in the last call to
		 *  'RenderSupport.configureBackBuffer()'. Beware: changing this value does not actually
		 *  resize the back buffer; the setter should only be used to inform Starling about the
		 *  size of a back buffer it can't control (shared context situations).
		 */
		public function get backBufferHeight():int  { return mBackBufferHeight; }
		public function set backBufferHeight( value:int ):void  { mBackBufferHeight = value; }

		// clipping

		/** The clipping rectangle can be used to limit rendering in the current render target to
		 *  a certain area. This method expects the rectangle in stage coordinates. Internally,
		 *  it uses the 'scissorRectangle' of stage3D, which works with pixel coordinates.
		 *  Any pushed rectangle is intersected with the previous rectangle; the method returns
		 *  that intersection. */
		public function pushClipRect( rectangle:Rectangle ):Rectangle
		{
			if (mClipRectStack.length < mClipRectStackSize + 1)
				mClipRectStack.push(new Rectangle());

			mClipRectStack[mClipRectStackSize].copyFrom(rectangle);
			rectangle = mClipRectStack[mClipRectStackSize];

			// intersect with the last pushed clip rect
			if (mClipRectStackSize > 0)
				RectangleUtil.intersect(rectangle, mClipRectStack[mClipRectStackSize - 1],
										rectangle);

			++mClipRectStackSize;
			applyClipRect();

			// return the intersected clip rect so callers can skip draw calls if it's empty
			return rectangle;
		}

		/** Restores the clipping rectangle that was last pushed to the stack. */
		public function popClipRect():void
		{
			if (mClipRectStackSize > 0)
			{
				--mClipRectStackSize;
				applyClipRect();
			}
		}

		/** Updates the context3D scissor rectangle using the current clipping rectangle. This
		 *  method is called automatically when either the render target, the projection matrix,
		 *  or the clipping rectangle changes. */
		public function applyClipRect():void
		{
			finishQuadBatch();

			var context:Context3D = Starling.context;
			if (context == null)
				return;

			if (mClipRectStackSize > 0)
			{
				var rect:Rectangle = mClipRectStack[mClipRectStackSize - 1];
				sRectangle.setTo(rect.x, rect.y, rect.width, rect.height);

				var width:int      = mRenderTarget ? mRenderTarget.root.nativeWidth : mBackBufferWidth;
				var height:int     = mRenderTarget ? mRenderTarget.root.nativeHeight : mBackBufferHeight;

				// convert to pixel coordinates
				MatrixUtil.transformCoords(mProjectionMatrix, rect.x, rect.y, sPoint);
				sRectangle.x = Math.max(0, (sPoint.x + 1) / 2) * width;
				sRectangle.y = Math.max(0, (-sPoint.y + 1) / 2) * height;

				MatrixUtil.transformCoords(mProjectionMatrix, rect.right, rect.bottom, sPoint);
				sRectangle.right = Math.min(1, (sPoint.x + 1) / 2) * width;
				sRectangle.bottom = Math.min(1, (-sPoint.y + 1) / 2) * height;

				// an empty rectangle is not allowed, so we set it to the smallest possible size
				// if the bounds are outside the visible area.
				if (sRectangle.width < 1 || sRectangle.height < 1)
					sRectangle.setTo(0, 0, 1, 1);

				context.setScissorRectangle(sRectangle);
			} else
			{
				context.setScissorRectangle(null);
			}
		}

		// optimized quad rendering

		/** Adds a quad to the current batch of unrendered quads. If there is a state change,
		 *  all previous quads are rendered at once, and the batch is reset. */
		public function batchQuad( quad:Quad, parentAlpha:Number,
								   texture:Texture = null, smoothing:String = null ):void
		{
			if (mQuadBatches[mCurrentQuadBatchID].isStateChange(quad.tinted, parentAlpha, texture,
																smoothing, mBlendMode))
			{
				finishQuadBatch();
			}

			mQuadBatches[mCurrentQuadBatchID].addQuad(quad, parentAlpha, texture, smoothing,
													  mModelViewMatrix, mBlendMode);
		}

		/** Renders the current quad batch and resets it. */
		public function finishQuadBatch():void
		{
			var currentBatch:QuadBatch = mQuadBatches[mCurrentQuadBatchID];

			if (currentBatch.numQuads != 0)
			{
				currentBatch.renderCustom(mProjectionMatrix);
				currentBatch.reset();

				++mCurrentQuadBatchID;
				++mDrawCount;

				if (mQuadBatches.length <= mCurrentQuadBatchID)
					mQuadBatches.push(new QuadBatch());
			}
		}

		/** Resets matrix stack, blend mode, quad batch index, and draw count. */
		public function nextFrame():void
		{
			resetMatrix();
			mBlendMode = BlendMode.NORMAL;
			mCurrentQuadBatchID = 0;
			mDrawCount = 0;
		}

		// other helper methods

		/** Deprecated. Call 'setBlendFactors' instead. */
		public static function setDefaultBlendFactors( premultipliedAlpha:Boolean ):void
		{
			setBlendFactors(premultipliedAlpha);
		}

		/** Sets up the blending factors that correspond with a certain blend mode. */
		public static function setBlendFactors( premultipliedAlpha:Boolean, blendMode:String = "normal" ):void
		{
			var blendFactors:Array = BlendMode.getBlendFactors(blendMode, premultipliedAlpha);
			Starling.context.setBlendFactors(blendFactors[0], blendFactors[1]);
		}

		/** Clears the render context with a certain color and alpha value. */
		public static function clear( rgb:uint = 0, alpha:Number = 0.0 ):void
		{
			Starling.context.clear(
				Color.getRed(rgb) / 255.0,
				Color.getGreen(rgb) / 255.0,
				Color.getBlue(rgb) / 255.0,
				alpha);
		}

		/** Clears the render context with a certain color and alpha value. */
		public function clear( rgb:uint = 0, alpha:Number = 0.0 ):void
		{
			RenderSupport.clear(rgb, alpha);
		}

		/** Assembles fragment- and vertex-shaders, passed as Strings, to a Program3D. If you
		 *  pass a 'resultProgram', it will be uploaded to that program; otherwise, a new program
		 *  will be created on the current Stage3D context. */
		public static function assembleAgal( vertexShader:String, fragmentShader:String,
											 resultProgram:Program3D = null ):Program3D
		{
			if (resultProgram == null)
			{
				var context:Context3D = Starling.context;
				if (context == null)
					throw new MissingContextError();
				resultProgram = context.createProgram();
			}

			resultProgram.upload(
				sAssembler.assemble(Context3DProgramType.VERTEX, vertexShader),
				sAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentShader));

			return resultProgram;
		}

		// statistics

		/** Raises the draw count by a specific value. Call this method in custom render methods
		 *  to keep the statistics display in sync. */
		public function raiseDrawCount( value:uint = 1 ):void  { mDrawCount += value; }

		/** Indicates the number of stage3D draw calls. */
		public function get drawCount():int  { return mDrawCount; }

	}
}
