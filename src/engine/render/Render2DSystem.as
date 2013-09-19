/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.render
{
	import engine.core.Parts;
	import engine.core.System;

	public class Render2DSystem extends System
	{
		public var render2DParts:Parts;
		public var camera2DParts:Parts;

		public function Render2DSystem() {
		}

		override public function start():void {
			render2DParts = engine.getParts(TransformPart);
			camera2DParts = engine.getParts(Camera2DPart);
		}

		override public function render():void {

			var camera2DPart:Camera2DPart = camera2DParts.head;
			while (camera2DPart) {

				camera2DPart = camera2DPart.next;
			}


			var render2DPart:TransformPart = render2DParts.head;
			while (render2DPart) {

				render2DPart = render2DPart.next;
			}
		}
	}
}
