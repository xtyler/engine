/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.display
{
	import engine.core.Parts;
	import engine.core.System;

	import flash.display.DisplayObject;

	public class DisplaySystem extends System
	{
		public var displayParts:Parts;

		public function DisplaySystem() {
		}

		override public function start():void {
			displayParts = engine.getParts(DisplayPart);
		}

		override public function update():void {

			var part:DisplayPart = displayParts.head;
			while (part) {

				var target:DisplayObject = part.display.target;
				if (target) {
					target.x = part.transform.position.x;
					target.y = part.transform.position.y;
					target.scaleX = part.transform.scale.x;
					target.scaleY = part.transform.scale.y;
					target.rotation = part.transform.rotation.z;
					target.alpha = part.display.alpha;
				}

				part = part.next;
			}
		}
	}
}
