/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.display
{
	import engine.core.Parts;
	import engine.core.System;

	public class DisplaySystem extends System
	{
		public var displayObjectParts:Parts;
		
		public function DisplaySystem() {
		}

		override public function start():void {
			displayObjectParts = engine.getParts(DisplayPart);
		}

		override public function update():void {
		}
	}
}
