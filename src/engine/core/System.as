/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.core
{
	import engine.time.Time;

	public class System
	{
		public var initialized:Boolean;
		
		public var engine:Engine;
		public var prev:System;
		public var next:System;
		
		public function System()
		{
		}
		
		public function start(time:Time):void
		{
		}
		
		public function fixedUpdate(time:Time):void
		{
		}
		
		public function update(time:Time):void
		{
		}
		
		public function render(time:Time):void
		{
		}
	}
}
