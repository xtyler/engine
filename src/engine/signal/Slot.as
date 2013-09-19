/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.signal
{
	public class Slot
	{
		public var enabled:Boolean = true;

		public var listener:Function;
		public var priority:int;
		public var once:Boolean;

		public var next:Slot;

		public function Slot() {
		}
	}
}
