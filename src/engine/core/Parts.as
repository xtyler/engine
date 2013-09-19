/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.core
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	public class Parts
	{
		public var invalidated:Boolean;
		public var partType:Class;
		public var required:Definition;

		public var partLookup:Dictionary = new Dictionary();
		public var partPool:*;
		
		public var head:*;
		public var tail:*;
		
		public var next:Parts;

		public function Parts(partType:Class) {
			this.partType = partType;
			partPool = new partType();
			if (!("prev" in partPool) || !("next" in partPool)) {
				throw new Error("Part " + getQualifiedClassName(partType).split("::").pop() + " must implement public variables 'prev' and 'next'.");
			}
			
			if ("required" in partType) {
				var definition:Object = partType.required;
				for (var name:String in definition) {
					var required:Definition = new Definition();
					required.name = name;
					required.type = definition[name];
					required.next = this.required;
					this.required = required;
				}
			} else {
				throw new Error("Part " + getQualifiedClassName(partType).split("::").pop() + " must implement public static variable 'required'.");
			}
		}

		public function add(entity:Entity):* {
			var part:* = partLookup[entity];
			if (part) {
				return part;
			} else if (partPool) {
				part = partPool;
				partPool = part.next;
			} else {
				part = new partType;
			}

			// assign required components
			var required:Definition = this.required;
			while (required) {
				var type:Class = required.type;
				
				var component:Component = entity.firstComponent;
				while (component) {
					if (component is type) {
						part[required.name] = component;
						break;
					}
					component = component.nextComponent;
				}
				
				if (!component) {
					return null;
				}
				required = required.next;
			}
			
			var before:*;
			var beforeEntity:Entity = entity.nextEntity;
			while (beforeEntity) {
				before = partLookup[beforeEntity];
				if (before) {
					break;
				}
				beforeEntity = beforeEntity.nextEntity;
			}

			if (before) {
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

			partLookup[entity] = part;
			invalidated = true;

			return part;
		}

		public function remove(entity:Entity):void {
			var part:* = partLookup[entity];
			if (!part) {
				return;
			}

			var required:Definition = this.required;
			while (required) {
				part[required.name] = null;
				required = required.next;
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
			part.next = partPool;
			partPool = part;

			delete partLookup[entity];
			invalidated = true;
		}
	}
}