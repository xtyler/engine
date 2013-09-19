/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.core
{
	import engine.render.Transform;
	import engine.time.TimeSystem;

	public class Engine
	{
		public var time:TimeSystem;

		public var firstEntity:Entity;
		public var lastEntity:Entity;

		public var firstSystem:System;
		public var lastSystem:System;

		public var parts:Parts;

		public function Engine() {
			firstSystem = lastSystem = new TimeSystem(this);
			firstSystem.engine = this;
		}

		public function hasEntity(entity:Entity):Boolean {
			return entity && entity.engine == this;
		}

		public function getEntity(name:String):Entity {
			var entity:Entity = firstEntity;
			while (entity) {
				if (entity.name == name) {
					return entity;
				}
				entity = entity.nextEntity;
			}
			return null;
		}

		public function addEntity(entity:Entity, before:Entity = null):Entity {
			if (!entity || (entity.engine == this && entity.nextEntity == before)) {
				return entity;
			} else if (entity.engine) {
				entity.engine.removeEntity(entity);
			}

			var transform:Transform = entity.getComponent(Transform);
			if (transform && transform.parent) {
				transform.parent.remove(transform);
			}

			if (before && before.engine == this) {
				if (before.prevEntity) {
					before.prevEntity.nextEntity = entity;
					entity.prevEntity = before.prevEntity;
				} else {
					firstEntity = entity;
				}
				entity.nextEntity = before;
				before.prevEntity = entity;
			} else {
				if (lastEntity) {
					lastEntity.nextEntity = entity;
					entity.prevEntity = lastEntity;
				} else {
					firstEntity = entity;
				}
				lastEntity = entity;
			}

			entityAdded(entity);

			return entity;
		}

		public function removeEntity(entity:Entity):Entity {
			if (!entity || entity.engine != this) {
				return entity;
			}

			entityRemoved(entity);

			if (entity.prevEntity) {
				entity.prevEntity.nextEntity = entity.nextEntity;
			} else {
				firstEntity = entity.nextEntity;
			}

			if (entity.nextEntity) {
				entity.nextEntity.prevEntity = entity.prevEntity;
			} else {
				lastEntity = entity.prevEntity;
			}

			entity.prevEntity = null;
			entity.nextEntity = null;

			return entity;
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
				system = system.nextSystem;
			}
			return null;
		}

		public function addSystem(system:System, before:System = null):* {
			if (!system || (system.engine == this && system.nextSystem == before)) {
				return system;
			} else if (system.engine) {
				system.engine.removeSystem(system);
			}
			
			// check to ensure System type is unique
			var type:Class = system['constructor'];
			var search:System = firstSystem;
			while (search) {
				if (search is type) {
					return search;
				}
				search = search.nextSystem;
			}

			if (before && before.engine == this) {
				if (before.prevSystem) {
					before.prevSystem.nextSystem = system;
					system.prevSystem = before.prevSystem;
				} else {
					firstSystem = system;
				}
				system.nextSystem = before;
				before.prevSystem = system;
			} else {
				if (lastSystem) {
					lastSystem.nextSystem = system;
					system.prevSystem = lastSystem;
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

			if (system.prevSystem) {
				system.prevSystem.nextSystem = system.nextSystem;
			} else {
				firstSystem = system.nextSystem;
			}

			if (system.nextSystem) {
				system.nextSystem.prevSystem = system.prevSystem;
			} else {
				lastSystem = system.prevSystem;
			}

			system.prevSystem = null;
			system.nextSystem = null;
			system.engine = null;
			return system;
		}

		public function getParts(partType:Class):Parts {
			var parts:Parts = this.parts;
			while (parts) {
				if (parts.partType == partType) {
					return parts;
				}
				parts = parts.next;
			}

			parts = new Parts(partType);
			parts.next = this.parts;
			this.parts = parts;

			// search entire 
			var entity:Entity = firstEntity;
			while (entity) {

				// validate required component types
				var required:Definition = parts.required;
				while (required) {
					var component:Component = entity.firstComponent;
					while (component) {
						if (component is required.type) {
							break;
						}
						component = component.nextComponent;
					}
					if (!component) {				// requirement was not found
						break;
					}
					required = required.next;
				}

				if (!required) {					// all requirements were met
					parts.add(entity);
				}

				entity = entity.nextEntity;
			}

			return parts;
		}


		public function entityAdded(entity:Entity):void {
			// update reference to engine throughout hierarchy
			var stop:Entity = entity.lastEntity.nextEntity;
			while (entity != stop) {
				entity.engine = this;

				// update part lists
				var parts:Parts = this.parts;
				while (parts) {

					// validate required component types
					var required:Definition = parts.required;
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
						parts.add(entity);
					}

					parts = parts.next;
				}

				entity = entity.nextEntity;
			}
		}

		public function entityRemoved(entity:Entity):void {
			// update reference to engine throughout hierarchy
			var current:Entity = entity;
			var stop:Entity = entity.lastEntity.nextEntity;
			while (current != stop) {
				current.engine = null;

				// update part lists
				var parts:Parts = this.parts;
				while (parts) {
					if (parts.partLookup[entity]) {
						parts.remove(entity);
					}
					parts = parts.next;
				}

				current = current.nextEntity;
			}
		}

		public function entityChanged(entity:Entity, component:Component):void {
			// update part lists
			var parts:Parts = this.parts;
			while (parts) {

				// initial check to verify relevance
				var required:Definition = parts.required;
				while (required) {
					if (component is required.type) {	// component is relevant to this list
						break;
					}
					required = required.next;
				}

				if (required) {
					// validate required component types
					required = parts.required;
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

					var part:* = parts.partLookup[entity];
					if (!required) {					// all requirements were met
						if (!part) {
							parts.add(entity);
						}
					} else if (part) {
						parts.remove(entity);
					}
				}

				parts = parts.next;
			}
		}
	}
}
