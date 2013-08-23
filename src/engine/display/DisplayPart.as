/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.display
{
	import engine.core.Component;
	import engine.render.Transform;

	public class DisplayPart
	{
		[Required]
		public var transform:Transform;
		
		[Required]
		public var displayProperties:Component;
		
		public function DisplayPart() {
		}
	}
}
