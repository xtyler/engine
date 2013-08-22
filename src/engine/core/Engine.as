/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.core
{
	import engine.core.Entity;
	import engine.data.Part;
	import engine.data.PartList;
	import engine.data.PartComponent;
	import engine.render.Transform;

	public class Engine
	{
		public var firstSystem:System;
		public var lastSystem:System;
		
		public var firstPartList:PartList;
		
		public var firstEntity:Entity;
		public var lastEntity:Entity;
		
		public function Engine()
		{
		}

		public function getPartList(partType:Class):PartList {
			var partList:PartList = firstPartList;
			while (partList) {
				if (partList.partType == partType) {
					return partList;
				}
			}

			partList = new PartList(partType);
			partList.next = firstPartList;
			firstPartList = partList;
			
			var entity:Entity = firstEntity;
			while (entity) {
				
			}
			
			return partList;
		}
		
		public function hasSystem(system:System):Boolean {
			return system && system.engine == this;
		}

		public function getSystem(type:Class):* {
			var system:System = firstSystem;
			while (system) {
				if (system is type) {
					return system;
				}
				system = system.next;
			}
			return null;
		}

		public function addSystem(system:System, before:System = null):* {
			if (!system || (system.engine == this && system.next == before)) {
				return system;
			} else if (system.engine) {
				system.engine.removeSystem(system);
			}

			if (before && before.engine == this) {
				if (before.prev) {
					before.prev.next = system;
					system.prev = before.prev;
				} else {
					firstSystem = system;
				}
				system.next = before;
				before.prev = system;
			} else {
				if (lastSystem) {
					lastSystem.next = system;
					system.prev = lastSystem;
				} else {
					firstSystem = system;
				}
				lastSystem = system;
			}
			system.engine = this;
			return system;
		}

		public function removeSystem(system:System):* {
			if (!system || system.engine != this) {
				return system;
			}

			if (system.prev) {
				system.prev.next = system.next;
			} else {
				firstSystem = system.next;
			}

			if (system.next) {
				system.next.prev = system.prev;
			} else {
				lastSystem = system.prev;
			}

			system.prev = null;
			system.next = null;
			system.engine = null;
			return system;
		}


		public function hasEntity(entity:Entity):Boolean {
			return entity && entity.engine == this;
		}

		public function getEntity(name:String):* {
			var entity:Entity = firstEntity;
			while (entity) {
				if (entity.name == name) {
					return entity;
				}
				entity = entity.next;
			}
			return null;
		}

		public function addEntity(entity:Entity, before:Entity = null):* {
			if (!entity || (entity.engine == this && entity.next == before)) {
				return entity;
			} else if (entity.engine) {
				entity.engine.removeEntity(entity);
			}
			
			var transform:Transform = entity.getComponent(Transform);
			if (transform && transform.parent) {
				transform.parent.remove(transform);
			}

			if (before && before.engine == this) {
				if (before.prev) {
					before.prev.next = entity;
					entity.prev = before.prev;
				} else {
					firstEntity = entity;
				}
				entity.next = before;
				before.prev = entity;
			} else {
				if (lastEntity) {
					lastEntity.next = entity;
					entity.prev = lastEntity;
				} else {
					firstEntity = entity;
				}
				lastEntity = entity;
			}
			
			entityAdded(entity);
			
			return entity;
		}

		public function removeEntity(entity:Entity):* {
			if (!entity || entity.engine != this) {
				return entity;
			}
			
			entityRemoved(entity);

			if (entity.prev) {
				entity.prev.next = entity.next;
			} else {
				firstEntity = entity.next;
			}

			if (entity.next) {
				entity.next.prev = entity.prev;
			} else {
				lastEntity = entity.prev;
			}

			entity.prev = null;
			entity.next = null;
			
			return entity;
		}


		public function entityAdded(entity:Entity):void {
			// update reference to engine throughout hierarchy
			var stop:Entity = entity.last.next;
			while (entity != stop) {
				entity.engine = this;

				// update part lists
				var partList:PartList = firstPartList;
				while (partList) {

					// validate required component types
					var required:PartComponent = partList.required;
					while (required) {
						var component:Component = entity.firstComponent;
						while (component) {
							if (component is required.type) {
								break;
							}
						}
						if (!component) {				// requirement was not found
							break;
						}
						required = required.next;
					}

					if (!required) {					// all requirements were met
						partList.add(entity);
					}

					partList = partList.next;
				}

				entity = entity.next;
			}
		}

		public function entityRemoved(entity:Entity):void {
			// update reference to engine throughout hierarchy
			var current:Entity = entity;
			var stop:Entity = entity.last.next;
			while (current != stop) {
				current.engine = null;

				// update part lists
				var partList:PartList = firstPartList;
				while (partList) {
					if (partList.partLookup[entity]) {
						partList.remove(entity);
					}
					partList = partList.next;
				}

				current = current.next;
			}
		}

		public function entityChanged(entity:Entity, component:Component):void {
			// update part lists
			var partList:PartList = firstPartList;
			while (partList) {

				// initial check to verify relevance
				var required:PartComponent = partList.required;
				while (required) {
					if (component is required.type) {	// component is relevant to this list
						break;
					}
					required = required.next;
				}

				if (required) {
					// validate required component types
					required = partList.required;
					while (required) {
						component = entity.firstComponent;
						while (component) {
							if (component is required.type) {
								break;
							}
						}
						if (!component) {				// requirement was not found
							break;
						}
						required = required.next;
					}

					var part:Part = partList.partLookup[entity];
					if (!required) {					// all requirements were met
						if (!part) {
							partList.add(entity);
						}
					} else if (part) {
						partList.remove(entity);
					}
				}

				partList = partList.next;
			}
		}
	}
}
