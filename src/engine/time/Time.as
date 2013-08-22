/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.time
{
	import engine.core.Engine;
	import engine.core.System;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;

	/**
	 * Time is a core system responsible for running updates on all other
	 * systems, and for providing time measurement in seconds.
	 */
	public class Time extends System
	{
		public var total:Number = 0;
		public var delta:Number = 0;
		public var fixed:Number = 0;
		public var fixedDelta:Number = 0.02;
		public var scale:Number = 1;

		private var totalMs:Number = 0;
		private var fixedMs:Number = 0;
		private var systemMs:Number;
		private var ticker:DisplayObject;

		public function Time(engine:Engine) {
			this.engine = engine;

			ticker = new Shape();
			ticker.addEventListener(Event.EXIT_FRAME, tick);
		}

		private function tick(event:Event):void {
			
			// ====== Calculate Time ====== //
			
			var currentMs:Number = new Date().getTime();
			// keep calculations in Milliseconds to reduce floating point errors.
			if (systemMs) {
				var deltaMs:Number = scale * (currentMs - systemMs);
				totalMs += deltaMs;
				delta = deltaMs / 1000;
				total = totalMs / 1000;
			}
			systemMs = currentMs;
			
			// ====== Update Systems ====== //
			
			// initialize systems
			var system:System = engine.firstSystem;
			while (system) {
				if (!system.initialized) {
					system.start(this);
					system.initialized = true;
				}
				system = system.next;
			}

			// run none->all updates tied to a fixed interval
			if (scale > 0) {
				while (fixedMs <= totalMs) {
					fixed = fixedMs / 1000;
					system = engine.firstSystem;
					while (system) {
						system.fixedUpdate(this);
						system = system.next;
					}
					fixedMs += fixedDelta * 1000;
				}
			} else if (scale < 0) {
				while (fixedMs >= totalMs) {
					fixed = fixedMs / 1000;
					system = engine.firstSystem;
					while (system) {
						system.fixedUpdate(this);
						system = system.next;
					}
					fixedMs -= fixedDelta * 1000;
				}
			}

			// run regular updates
			system = engine.firstSystem;
			while (system) {
				system.update(this);
				system = system.next;
			}

			// run final updates for rendering
			system = engine.firstSystem;
			while (system) {
				system.render(this);
				system = system.next;
			}
		}
	}
}
