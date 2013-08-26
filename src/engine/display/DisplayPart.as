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
		public var display:Display;

		public var prev:DisplayPart;
		public var next:DisplayPart;

		public static var required:Object = {
			transform:Transform,
			display:Display
		};
	}
}
