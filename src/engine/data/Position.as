/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.data
{
	public class Position
	{
		// IPosition
		public var stepSize:Number;
		public var skipSize:Number;
		
		// IProgress
		public var current:Number;
//		public var percent:Number;
		public var size:Number;//or length
		
		// IRange
		public var begin:Number;
//		public var end:Number;
		
		// new
		public var loop:Boolean;
		
		public function Position() {
		}
	}
}
