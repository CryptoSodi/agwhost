// =================================================================================================
//
//	Starling Framework
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package org.starling.core
{
	import flash.system.System;

	import org.ash.tick.FrameTickProvider;
	import org.starling.display.BlendMode;
	import org.starling.display.Quad;
	import org.starling.display.Sprite;
	import org.starling.text.BitmapFont;
	import org.starling.text.TextField;
	import org.starling.utils.HAlign;
	import org.starling.utils.VAlign;

	/** A small, lightweight box that displays the current framerate, memory consumption and
	 *  the number of draw calls per frame. The display is updated automatically once per frame. */
	internal class StatsDisplay extends Sprite
	{
		private var mBackground:Quad;
		private var mTextField:TextField;

		private var mFrameCount:int   = 0;
		private var mTotalTime:Number = 0;

		private var mFps:Number       = 0;
		private var mMemory:Number    = 0;
		private var mDrawCount:int    = 0;

		/** Creates a new Statistics Box. */
		public function StatsDisplay()
		{
			mBackground = new Quad(50, 25, 0x0);
			mTextField = new TextField(48, 25, "", BitmapFont.MINI, BitmapFont.NATIVE_SIZE, 0xffffff);
			mTextField.x = 2;
			mTextField.hAlign = HAlign.LEFT;
			mTextField.vAlign = VAlign.TOP;

			addChild(mBackground);
			addChild(mTextField);

			blendMode = BlendMode.NONE;

			FrameTickProvider.instance.addFrameListener(onEnterFrame);
			mTotalTime = mFrameCount = 0;
			update();
		}

		private function onEnterFrame( passedTime:Number ):void
		{
			mTotalTime += passedTime;
			mFrameCount++;

			if (mTotalTime > 1.0)
			{
				update();
				mFrameCount = mTotalTime = 0;
			}
		}

		/** Updates the displayed values. */
		public function update():void
		{
			mFps = mTotalTime > 0 ? mFrameCount / mTotalTime : 0;
			mMemory = System.totalMemory * 0.000000954; // 1.0 / (1024*1024) to convert to MB

			mTextField.text = "FPS: " + mFps.toFixed(mFps < 100 ? 1 : 0) +
				"\nMEM: " + mMemory.toFixed(mMemory < 100 ? 1 : 0) +
				"\nDRW: " + Math.max(0, mDrawCount - 2); // ignore self 
		}

		/** The number of Stage3D draw calls per second. */
		public function get drawCount():int  { return mDrawCount; }
		public function set drawCount( value:int ):void  { mDrawCount = value; }

		/** The current frames per second (updated once per second). */
		public function get fps():Number  { return mFps; }
		public function set fps( value:Number ):void  { mFps = value; }

		/** The currently required system memory in MB. */
		public function get memory():Number  { return mMemory; }
		public function set memory( value:Number ):void  { mMemory = value; }
	}
}
