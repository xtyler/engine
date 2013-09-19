/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.data
{
	import engine.core.Component;

	public class Range extends Component
	{

		public var position:Number;
		public var percent:Number;
		public var length:Number;

		public var begin:Number;
		public var end:Number;

		public var stepSize:Number;
		public var skipSize:Number;

		public var isPlaying:Boolean;


		public function Range() {
		}

		public function stepForward():void {}
		public function stepBackward():void {}
		public function skipForward():void {}
		public function skipBackward():void {}

		public function play():void {}
		public function pause():void {}
		public function stop():void {}
		public function seek():void {}
	}
}
