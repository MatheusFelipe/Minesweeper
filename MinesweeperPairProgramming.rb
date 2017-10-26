require 'scanf'
require 'matrix'

class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

#$celula = Struct.new(:valor, :flag, :descoberta)
$mine = '#'

class celula
	attr_accessor :valor, :flag, :descoberta
	def initialize(valor, flag = false, descoberta = false)
		@valor = valor
		@flag = flag
		@descoberta = descoberta
	end
	
	def mine?
		if @valor == $mine
			return true
		else return false
		end
	end
	
	def flag?
		return @flag
	end
	
	def descoberta?
		return @descoberta
	end
	
end

class Minesweeper
	attr_accessor :width, :height, :num_mines, :still_playing, :victory, :tabuleiro
	def initialize(width, height, num_mines)
        @width = width
        @height = height
        if num_mines < width * height
            @num_mines = num_mines
        else #limite de minas no tabuleiro
            puts "Número máximo de minas excedido, o tabuleiro terá apenas uma célula sem mina"
            @num_mines = width * height - 1
		end
        @still_playing = true
        @victory = false
	end
	
	def qtd_mina(x, y)
		if x >= 0 && y >= 0 && x <= @height - 1 && y <= @width - 1
			if @tabuleiro[x, y].valor == '#'
				return 1
			else return 0
			end
		end
		return 0
	end
	
	def ajusta_numero_minas_vizinhas(x, y)
	    #não precisa ajustar se for bomba
        if @tabuleiro[x, y].valor != '#'
			ax = [-1, -1, -1, 0, 0, 1, 1, 1]
			ay = [-1, 0, 1, -1, 1, -1, 0, 1]
            vizinhas = 0
			(0...8).each do |i|
				vizinhas += qtd_mina(x + ax[i], y + ay[i])
			end
            #preenche célula com número de vizinhos
            if vizinhas == 0
                @tabuleiro[x, y].valor = " "
            else
                @tabuleiro[x, y].valor = vizinhas
            end
        end
    end
	
	def preenche_tabuleiro
	    #inicializa tabuleiro com altura e largura dadas
		@tabuleiro = Matrix.build(@height,@width){0}
		#método que distribui aleatoriamente as minas
		array_minas =  (1..@height * @width).to_a.shuffle.take(@num_mines)
		#loop para inserir as minas no tabuleiro
		(0...@height).each do |i|
			(0...@width).each do|j|
				aux = (i) * @width + (j) + 1
				if array_minas.find_index(aux)
					@tabuleiro.[]=(i, j, $celula.new('#',false,false))
				else
					@tabuleiro.[]=(i, j, $celula.new("0",false,false))
				end
			end
		end
		#loop para ajustar o número de minas vizinhas
		(0...@height).each do |i|
			(0...@width).each do|j|
				ajusta_numero_minas_vizinhas(i, j)
			end
		end
	end
	
	def still_playing?
        count = 0
        pisou = false
        (0...@height).each do |i|
			(0...@width).each do|j|
                #conta se o número de células cobertas bate com o número de minas
				if @tabuleiro[i, j].descoberta == false
					count += 1
				end
				#verifica se pisou em uma mina
				if @tabuleiro[i, j].descoberta == true && @tabuleiro[i, j].valor == '#'
					pisou = true
				end
			end
		end
		#condição de vitória
		if count == @num_mines && !pisou
		    @victory = true
		    @still_playing = false
        #mid-game
        elsif count > @num_mines && !pisou
            @victory = false
            @still_playing = true
        #condição de derrota
        elsif count > @num_mines && pisou
            @victory = false
            @still_playing = false
        end
        return @still_playing
	end
	
	def victory?
	    still_playing?
	    #Já verifica as condições de derrota/vitória na função acima
        return @victory
	end
	
	def auxxx(x, y)
		if x >= 0 && y >= 0 && x <= @height - 1 && y <= @width - 1
			if @tabuleiro[x, y].valor == ' ' && !@tabuleiro[x, y].descoberta && !@tabuleiro[x, y].flag
                descobre_celulas_vizinhas_sem_mina(x, y)
            elsif @tabuleiro[x, y].valor != '#' && !@tabuleiro[x, y].descoberta && !@tabuleiro[x, y].flag
				@tabuleiro[x, y].descoberta = true
			end
		end
	end
	
    def descobre_celulas_vizinhas_sem_mina(x, y)
        @tabuleiro[x, y].descoberta = true
		ax = [-1, -1, -1, 0, 0, 1, 1, 1]
		ay = [-1, 0, 1, -1, 1, -1, 0, 1]
		(0...8).each do |i| 
			auxxx(x + ax[i], y + ay[i])
		end
    end
    
    def play(x, y)
        #Caso o jogo tenha acabado
        if !@still_playing
            puts "O jogo já está finalizado"
            return false
        end
        #Caso se jogue fora do tabuleiro
        if x < 0 || x >= @width || y < 0 || y >= @height
            puts "Jogada fora do tabuleiro"
            return false
        end
        #Caso se jogue onde já foi jogado
        if @tabuleiro[y, x].descoberta
            puts "Jogada já realizada"
            return false
        end
        #Caso se jogue e muma bandeira
        if @tabuleiro[y, x].flag
            puts "Jogada em célula com bandeira"
            return false
        end
        #Descobre a célula
        @tabuleiro[y, x].descoberta = true
        #Jogada válida
        if @tabuleiro[y, x].valor == '#' #Em uma mina
            @still_playing = false
            @victory = false
            puts "Essa não! Você pisou em uma mina :("
            return true
        elsif @tabuleiro[y, x].valor.instance_of? Integer #Em uma célula vizinha de uma mina
            return true
        else #Em uma célula sem minas vizinhas
            descobre_celulas_vizinhas_sem_mina(y, x)
            return true
        end
        
    end
    
    def flag(x, y)
        #Caso o jogo tenha acabado
        if !@still_playing
            puts "O jogo já está finalizado"
            return false
        end
        #Caso se jogue fora do tabuleiro
        if x < 0 || x >= @width || y < 0 || y >= @height
            puts "Flag fora do tabuleiro"
            return false
        end
        #Caso se jogue onde já foi jogado
        if @tabuleiro[y, x].descoberta
            puts "Célula já descoberta"
            return false
        end
        #jogada válida
        if @tabuleiro[y, x].flag
            @tabuleiro[y, x].flag = false
        else
            @tabuleiro[y, x].flag = true
        end
        return true
    end
    
    def board_state(xray = false)
        tab = Matrix.build(@height,@width){0}
		(0...@height).each do |i|
            (0...@width).each do|j|
				tab.[]=(i, j, $celula.new(@tabuleiro[i, j].valor, @tabuleiro[i, j].flag, @tabuleiro[i, j].descoberta))
			end
        end
        #Verifica se ainda está em jogo
        if still_playing?
            xray = false
        end
        #Passa as células desconhecidas como pontos, minas continuam minas se xray = true
        if xray
            (0...@height).each do |i|
                (0...@width).each do|j|
                    if tab[i, j].descoberta == false && tab[i, j].valor != '#'
                        tab[i, j].valor = '.'
                    end
                    if tab[i, j].flag && tab[i, j].valor != '#'
                        tab[i, j].valor = 'F'
                    end
                end
            end
        else
            (0...@height).each do |i|
                (0...@width).each do|j|
                    if tab[i, j].descoberta == false
                        tab[i, j].valor = '.'
                    end
                    if tab[i, j].flag
                        tab[i, j].valor = 'F'
                    end
                end
            end
        end
        return tab
    end
end

class SimplePrinter
    def print(tabuleiro)
        (0...tabuleiro.row_count()).each do |i|
            (0...tabuleiro.column_count()).each do|j|
                if tabuleiro[i,j].valor.instance_of? Integer
                    printf("%d ", tabuleiro[i,j].valor)
                else
                    printf("%c ", tabuleiro[i,j].valor)
                end
            end
            printf("\n")
        end 
    end
end

class PrettyPrinter #com eixos x e y
    def print(tabuleiro)
		m = Matrix.build(tabuleiro.row_count() + 1, tabuleiro.column_count() + 1){0}
		m.[]=(0, 0, '\\')
		(1..tabuleiro.row_count()).each do |i|
			(1..tabuleiro.column_count()).each do|j|
				m.[]=(i, j, tabuleiro[i - 1, j - 1].valor)
			end
		end
		(1..tabuleiro.row_count()).each do |i|
			m.[]=(i, 0, i - 1)
		end
		(1..tabuleiro.column_count()).each do |i|
			m.[]=(0, i, i - 1)
		end
        (0...m.row_count()).each do |i|
            (0...m.column_count()).each do|j|
                if m[i,j].instance_of? Integer
                    printf("%d ", m[i,j])
                else
                    printf("%c ", m[i,j])
                end
            end
            printf("\n")
        end 
    end
end


begin
	puts "MINE SWEEPER\n\n"
    puts "Digite a largura, altura e número de minas do tabuleiro: "
    input = scanf("%d %d %d")
    game = Minesweeper.new(input[0], input[1], input[2])
    game.preenche_tabuleiro
	puts
    PrettyPrinter.new.print(game.tabuleiro)

    while game.still_playing?
        entrada_valida = false
        valid_move = false
        valid_flag = false
        begin
            puts "\nDigite P para jogar, F para colocar bandeira ou S para sair: "
            tipo_jogada = scanf("%c")
            case tipo_jogada[0]
            when 'P', 'p'
                entrada_valida = true
                puts "Digite as coordenadas x e y: "
                jogada = scanf("%d %d")
                valid_move = game.play(jogada[0], jogada[1])
            when 'F', 'f'
                entrada_valida = true
                puts "Digite as coordenadas x e y: "
                jogada = scanf("%d %d")
                valid_move = game.flag(jogada[0], jogada[1])
            when 'S', 's'
                entrada_valida = true
                puts "Saindo do programa"
                exit
            end
            if !entrada_valida
                puts "Tipo de jogada não reconhecida, jogue novamente"
            end
        end until entrada_valida
        if valid_move or valid_flag
			Gem.win_platform? ? (system "cls") : (system "clear")
			puts "MINE SWEEPER\n\n"
            #printer = (rand > 0.5) ? SimplePrinter.new : PrettyPrinter.new
			printer = PrettyPrinter.new
            printer.print(game.board_state)
        end
    end
    
    puts "Fim do jogo!\n"
    if game.victory?
        puts "Você venceu!"
    else
        puts "Você perdeu! As minas eram:\n"
        PrettyPrinter.new.print(game.board_state(true))
    end
rescue SystemExit

rescue Exception => e
	puts e.message
	puts e.backtrace.inspect
	
    puts "Algum erro ocorreu. Reiniciando jogo: "
    retry
end
