extends CharacterBody2D
class_name Jogador

# Imagens utilizadas nesse projeto forão tiradas deste link e re-adaptadas 
# https://greenpixels.itch.io/pixel-art-assets-5





#Adicionando uma referência para o AnimationPlayer // Não sei o que faz
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

#Estados para selecionar execuções
enum states {
	IDLE,   # 0
	RUN, # 1
	JUMPING,   # 2
	FALL,
	JUMPINGJUMPING    # 3
}

const SPEED = 300 #Motor
const FRICTION = 1000 #Essa variavel é utilizada para deslizar
const JUMP_VELOCITY = -400.0 #Quanto o personagem pula
var _states = states.IDLE #Salva estado atual e configura quem será o proximo estado



#Padrão GDS
func _physics_process(delta: float) -> void:
	#Variaveis de controle, devem sempre serem atualizadas primeiro
	var direction := Input.get_axis("Left", "Right")
	var pular = Input.is_action_just_pressed("Jump")
	
	
	#Atualiza estado atual do personagem
	states_update(delta, direction, pular, FRICTION)
	
	#Aplica gravidade independente do estado do personagem
	if not is_on_floor():
		velocity += get_gravity() * delta
	#Não sei o que faz
	move_and_slide()

#Essa função é um grande switch case que executa o código de acordo com o estado atual
func states_update(delta: float, direction: float, pular : int, FRICTION : float) -> void:
	if get_states() == states.IDLE:
		go_idle(delta, direction, pular)
	if get_states() == states.RUN:
		go_run(delta, direction, pular, FRICTION)
	if get_states() == states.JUMPING:
		go_jump(delta, direction)
	if get_states() == states.FALL:
		go_fall(delta, pular)
	#if get_states() == states.JUMPINGJUMPING:
	#	go_jumping_jumping()
	
#Código do personagem em IDLE
func go_idle(delta : float, direction: float, pular : int) -> void:
	animation.play("Idle")
	
	if direction and is_on_floor():
		_states = states.RUN
	if pular and is_on_floor():
		_states = states.JUMPING
		
	if velocity.x != 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	#if not is_on_floor():
	#	_states = states.FALL

#Código do personagem correndo
func go_run(delta : float, direction : float,pular : int, FRICTION : float) -> void:
	animation.play("Andando")
	
	
	if not direction:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		if velocity.x == 0:
			animation.play("Idle")
			_states = states.IDLE
	else:
		velocity.x = SPEED * direction
		
	if direction == 1:
		animation.flip_h = false
	elif direction == -1:
		animation.flip_h = true
	
	if not is_on_floor():
		_states = states.FALL
		
	if pular and is_on_floor():
		_states = states.JUMPING
	
#Código do personagem pulando
func go_jump(delta: float, direction : float) -> void:
	
	if is_on_floor():
		animation.play("Pulando")
		print("pulando")
		velocity.y = JUMP_VELOCITY
		velocity.x = SPEED * direction
			
	if (velocity.y >= 0):
		_states = states.FALL
	
#Código do personagem caindo
#nota: grávidade é aplicada externamente a queda
func go_fall(delta:float, pular : int) -> void:
	animation.play("Caindo")
	
	if is_on_floor():
		_states = states.IDLE
		
	#if pular and !is_on_floor():
	#	_states = states.JUMPINGJUMPING
	
#Função get padrão
func get_states():
	return _states
