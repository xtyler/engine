/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.core
{
	import engine.time.TimeSystem;

	public class System
	{
		public var initialized:Boolean;

		public var engine:Engine;
		public var prevSystem:System;
		public var nextSystem:System;

		public var abstract:uint;

		public function System() {
		}

		public function start():void {
		}

		public function update():void {
			abstract |= TimeSystem.UPDATE;
		}

		public function fixedUpdate():void {
			abstract |= TimeSystem.FIXED_UPDATE;
		}

		public function render():void {
			abstract |= TimeSystem.RENDER;
		}
	}
}
