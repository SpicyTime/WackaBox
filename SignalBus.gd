extends Node
# Health System
signal health_changed(new_health: int)
signal max_health_changed(new_max_health: int)
signal health_depleted
signal received_damage(damage: float)

# Game Manager
signal boxlet_count_changed(new_value)
signal game_restart
# Player
signal player_died
# Box
signal box_died
# Shop Item
