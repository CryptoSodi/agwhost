// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package org.starling.utils
{
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    
    import org.starling.errors.AbstractClassError;

    /** A utility class containing methods related to the Matrix class. */
    public class MatrixUtil
    {
        /** Helper object. */
        private static var sRawData:Vector.<Number> = 
            new <Number>[1, 0, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1];
        
        /** @private */
        public function MatrixUtil() { throw new AbstractClassError(); }
        
        /** Converts a 2D matrix to a 3D matrix. If you pass a 'resultMatrix',  
         *  the result will be stored in this matrix instead of creating a new object. */
        public static function convertTo3D(matrix:Matrix, resultMatrix:Matrix3D=null):Matrix3D
        {
            if (resultMatrix == null) resultMatrix = new Matrix3D();
            
            sRawData[0] = matrix.a;
            sRawData[1] = matrix.b;
            sRawData[4] = matrix.c;
            sRawData[5] = matrix.d;
            sRawData[12] = matrix.tx;
            sRawData[13] = matrix.ty;
            
            resultMatrix.copyRawDataFrom(sRawData);
            return resultMatrix;
        }
        
        /** Uses a matrix to transform 2D coordinates into a different space. If you pass a 
         *  'resultPoint', the result will be stored in this point instead of creating a new object.*/
        public static function transformCoords(matrix:Matrix, x:Number, y:Number,
                                               resultPoint:Point=null):Point
        {
            if (resultPoint == null) resultPoint = new Point();   
            
            resultPoint.x = matrix.a * x + matrix.c * y + matrix.tx;
            resultPoint.y = matrix.d * y + matrix.b * x + matrix.ty;
            
            return resultPoint;
        }
        
        /** Appends a skew transformation to a matrix (angles in radians). The skew matrix
         *  has the following form: 
         *  <pre>
         *  | cos(skewY)  -sin(skewX)  0 |
         *  | sin(skewY)   cos(skewX)  0 |
         *  |     0            0       1 |
         *  </pre> 
         */
        public static function skew(matrix:Matrix, skewX:Number, skewY:Number):void
        {
            var sinX:Number = Math.sin(skewX);
            var cosX:Number = Math.cos(skewX);
            var sinY:Number = Math.sin(skewY);
            var cosY:Number = Math.cos(skewY);
            
            matrix.setTo(matrix.a  * cosY - matrix.b  * sinX,
                         matrix.a  * sinY + matrix.b  * cosX,
                         matrix.c  * cosY - matrix.d  * sinX,
                         matrix.c  * sinY + matrix.d  * cosX,
                         matrix.tx * cosY - matrix.ty * sinX,
                         matrix.tx * sinY + matrix.ty * cosX);
        }
        
        /** Prepends a matrix to 'base' by multiplying it with another matrix. */
        public static function prependMatrix(base:Matrix, prep:Matrix):void
        {
            base.setTo(base.a * prep.a + base.c * prep.b,
                       base.b * prep.a + base.d * prep.b,
                       base.a * prep.c + base.c * prep.d,
                       base.b * prep.c + base.d * prep.d,
                       base.tx + base.a * prep.tx + base.c * prep.ty,
                       base.ty + base.b * prep.tx + base.d * prep.ty);
        }
        
        /** Prepends an incremental translation to a Matrix object. */
        public static function prependTranslation(matrix:Matrix, tx:Number, ty:Number):void
        {
            matrix.tx += matrix.a * tx + matrix.c * ty;
            matrix.ty += matrix.b * tx + matrix.d * ty;
        }
        
        /** Prepends an incremental scale change to a Matrix object. */
        public static function prependScale(matrix:Matrix, sx:Number, sy:Number):void
        {
            matrix.setTo(matrix.a * sx, matrix.b * sx, 
                         matrix.c * sy, matrix.d * sy,
                         matrix.tx, matrix.ty);
        }
        
        /** Prepends an incremental rotation to a Matrix object (angle in radians). */
        public static function prependRotation(matrix:Matrix, angle:Number):void
        {
            var sin:Number = Math.sin(angle);
            var cos:Number = Math.cos(angle);
            
            matrix.setTo(matrix.a * cos + matrix.c * sin,  matrix.b * cos + matrix.d * sin,
                         matrix.c * cos - matrix.a * sin,  matrix.d * cos - matrix.b * sin,
                         matrix.tx, matrix.ty);
        }
        
        /** Prepends a skew transformation to a Matrix object (angles in radians). The skew matrix
         *  has the following form: 
         *  <pre>
         *  | cos(skewY)  -sin(skewX)  0 |
         *  | sin(skewY)   cos(skewX)  0 |
         *  |     0            0       1 |
         *  </pre> 
         */
        public static function prependSkew(matrix:Matrix, skewX:Number, skewY:Number):void
        {
            var sinX:Number = Math.sin(skewX);
            var cosX:Number = Math.cos(skewX);
            var sinY:Number = Math.sin(skewY);
            var cosY:Number = Math.cos(skewY);
            
            matrix.setTo(matrix.a * cosY + matrix.c * sinY,
                         matrix.b * cosY + matrix.d * sinY,
                         matrix.c * cosX - matrix.a * sinX,
                         matrix.d * cosX - matrix.b * sinX,
                         matrix.tx, matrix.ty);
        }
    }
}