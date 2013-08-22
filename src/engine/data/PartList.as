/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.data
{
	public class PartList
	{
		public var head:Part;
		public var tail:Part;
		
		public var added:*;
		public var removed:*;

		public function PartList() {
		}

		public function has(part:Part):Boolean {
			return part && part.owner == this;
		}
		
		public function get(type:Class):* {
			var part:Part = head;
			while (part) {
				if (part is type) {
					return part;
				}
				part = part.next;
			}
			return null;
		}

		public function add(part:Part, before:Part = null):Part {
			if (!part || (part.owner == this && part.next == before)) {
				return part;
			} else if (part.owner) {
				part.owner.remove(part);
			}

			if (before && before.owner == this) {
				if (before.prev) {
					before.prev.next = part;
					part.prev = before.prev;
				} else {
					head = part;
				}
				part.next = before;
				before.prev = part;
			} else {
				if (tail) {
					tail.next = part;
					part.prev = tail;
				} else {
					head = part;
				}
				tail = part;
			}
			part.owner = this;

			if (added is Function) {
				added(part);
			}
			return part;
		}

		public function remove(part:Part):Part {
			if (!part || part.owner != this) {
				return part;
			}
			
			if (removed is Function) {
				removed(part);
			}
			
			if (part.prev) {
				part.prev.next = part.next;
			} else {
				head = part.next;
			}
			
			if (part.next) {
				part.next.prev = part.prev;
			} else {
				tail = part.prev;
			}

			part.prev = null;
			part.next = null;
			part.owner = null;
			return part;
		}
	}
}
