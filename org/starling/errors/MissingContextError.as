// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package org.starling.errors
{
    /** A MissingContextError is thrown when a Context3D object is required but not (yet) 
     *  available. */
    public class MissingContextError extends Error
    {
        /** Creates a new MissingContextError object. */
        public function MissingContextError(message:*="", id:*=0)
        {
            super(message, id);
        }
    }
}