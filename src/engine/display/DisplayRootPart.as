/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.display
{
	public class DisplayRootPart
	{
		[Required]
		public var displayRoot:DisplayRoot;

		public var prev:DisplayRootPart;
		public var next:DisplayRootPart;

		public static const required:Object = {
			displayRoot:DisplayRoot
		}
	}
}
