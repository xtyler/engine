/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.animation
{
	public class AnimationPart
	{
		[Required]
		public var animation:Animation;

		public var prev:AnimationPart;
		public var next:AnimationPart;

		public static const required:Object = {
			animation:Animation
		};
	}
}
