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

utils.add_data(require("prototypes.entity.warponium-ore"))

-- Категории
utils.add_data(require("prototypes.custom-category.warponium"))
utils.add_data(require("prototypes.items.modified"))
-- Звуки
utils.add_data(require("prototypes.other.sounds"))
utils.add_data(require("prototypes.other.explosions"))

-- Панелька
utils.add_data(require("prototypes.entity.warponium-solar-panel"))
utils.add_data(require("prototypes.items.warponium-solar-panel"))
utils.add_data(require("prototypes.recipes.warponium-solar-panel"))
utils.add_data(require("prototypes.technologies.warponium-solar-panel"))

-- Завод по переработке варпония
utils.add_data(require("prototypes.items.conversion-plant"))
utils.add_data(require("prototypes.recipes.conversion-plant"))
utils.add_data(require("prototypes.entity.conversion-plant"))
utils.add_data(require("prototypes.entity.terminal-drain"))

-- Контролирующий враг
utils.add_data(require("prototypes.entity.mind_control_unit"))

-- Варпониевый гиперкуб
utils.add_data(require("prototypes.items.warponium-hypercube"))
utils.add_data(require("prototypes.recipes.warponium-hypercube"))
utils.add_data(require("prototypes.technologies.warponium-hypercube"))

-- Консоль способностей корабля
utils.add_data(require("prototypes.entity.ship_abilities_console"))
utils.add_data(require("prototypes.items.ship_abilities_console"))
utils.add_data(require("prototypes.recipes.ship_abilities_console"))
utils.add_data(require("prototypes.technologies.ship_abilities_console"))

-- Варпониевый резервуар
utils.add_data(require("prototypes.entity.warponium-storage-tank"))
utils.add_data(require("prototypes.items.warponium-storage-tank"))
utils.add_data(require("prototypes.recipes.warponium-storage-tank"))

-- Power Armor MK3+ оборудование
utils.add_data(require("prototypes.items.pamk3_equipment"))
utils.add_data(require("prototypes.equipment.pamk3_equipment"))
utils.add_data(require("prototypes.recipes.pamk3_equipment"))
utils.add_data(require("prototypes.technologies.pamk3_equipment"))
