local utils = require("utils")

-- Лазер
utils.add_data(require("prototypes.items.kj_electric_laser"))
utils.add_data(require("prototypes.entity.kj_electric_laser"))
utils.add_data(require("prototypes.recipes.kj_electric_laser"))

-- Экстренный телепорт
utils.add_data(require("prototypes.items.emergency_return"))
utils.add_data(require("prototypes.technologies.emergency_return"))
utils.add_data(require("prototypes.recipes.emergency_return"))

-- Вооружение
utils.add_data(require("prototypes.items.exoskeleton"))
utils.add_data(require("prototypes.technologies.exoskeleton"))
utils.add_data(require("prototypes.recipes.exoskeleton"))
utils.add_data(require("prototypes.equipment.exoskeleton"))

-- Связанные тепловые трубы
utils.add_data(require("prototypes.entity.linked_heat_pipe"))
utils.add_data(require("prototypes.items.linked_heat_pipe"))
utils.add_data(require("prototypes.recipes.linked_heat_pipe"))
utils.add_data(require("prototypes.technologies.linked_heat_pipe"))

-- Кристаллы
utils.add_data(require("prototypes.entity.crystal"))
utils.add_data(require("prototypes.items.crystal"))
utils.add_data(require("prototypes.recipes.crystal"))
utils.add_data(require("prototypes.technologies.crystal"))

-- Звуки
utils.add_data(require("prototypes.other.sounds"))
