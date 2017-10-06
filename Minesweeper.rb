require 'scanf'
require 'matrix'

class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

$celula = Struct.new(:valor, :flag, :descoberta)

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
	
	def ajusta_numero_minas_vizinhas(x, y)
	    #não precisa ajustar se for bomba
        if @tabuleiro[x, y].valor != '#'
            vizinhas = 0
            #canto esquerdo superior
            if x > 0 && y > 0
                if @tabuleiro[x-1, y-1].valor == '#'
                    vizinhas += 1
                end
            end
            #célula superior
            if x > 0 
                if @tabuleiro[x-1, y].valor == '#'
                    vizinhas += 1
                end
            end
            #canto direito superior
            if x > 0 && y < @width - 1
                if @tabuleiro[x-1, y+1].valor == '#'
                    vizinhas += 1
                end
            end
            #célula esquerda
            if y > 0
                if @tabuleiro[x, y-1].valor == '#'
                    vizinhas += 1
                end
            end
            #célula direita
            if y < @width - 1
                if @tabuleiro[x, y+1].valor == '#'
                    vizinhas += 1
                end
            end
            #canto esquerdo inferior
            if x < @height - 1 && y > 0
                if @tabuleiro[x+1, y-1].valor == '#'
                    vizinhas += 1
                end
            end
            #célula inferior
            if x < @height - 1
                if @tabuleiro[x+1, y].valor == '#'
                    vizinhas += 1
                end
            end
            #canto direito inferior
            if x < @height - 1 && y < @width - 1
                if @tabuleiro[x+1, y+1].valor == '#'
                    vizinhas += 1
                end
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
                #conta se o número de células descoberta bate com o número de minas
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
	
    def descobre_celulas_vizinhas_sem_mina(x, y)
        @tabuleiro[x, y].descoberta = true
        #canto esquerdo superior
        if x > 0 && y > 0
            if @tabuleiro[x-1, y-1].valor == ' ' && !@tabuleiro[x-1, y-1].descoberta && !@tabuleiro[x-1, y-1].flag
                descobre_celulas_vizinhas_sem_mina(x - 1, y - 1)
            elsif @tabuleiro[x-1, y-1].valor != '#' && !@tabuleiro[x-1, y-1].descoberta && !@tabuleiro[x-1, y-1].flag
				@tabuleiro[x-1, y-1].descoberta = true
			end
        end
        #célula superior
        if x > 0 
            if @tabuleiro[x-1, y].valor == ' ' && !@tabuleiro[x-1, y].descoberta && !@tabuleiro[x-1, y].flag
                descobre_celulas_vizinhas_sem_mina(x - 1, y)
            elsif @tabuleiro[x-1, y].valor != '#' && !@tabuleiro[x-1, y].descoberta && !@tabuleiro[x-1, y].flag
				@tabuleiro[x-1, y].descoberta = true
			end
        end
        #canto direito superior
        if x > 0 && y < @width - 1
            if @tabuleiro[x-1, y+1].valor == ' ' && !@tabuleiro[x-1, y+1].descoberta && !@tabuleiro[x-1, y+1].flag
                descobre_celulas_vizinhas_sem_mina(x - 1, y + 1)
            elsif @tabuleiro[x-1, y+1].valor != '#' && !@tabuleiro[x-1, y+1].descoberta && !@tabuleiro[x-1, y+1].flag
				@tabuleiro[x-1, y+1].descoberta = true
			end
        end
        #célula esquerda
        if y > 0
            if @tabuleiro[x, y-1].valor == ' ' && !@tabuleiro[x, y-1].descoberta && !@tabuleiro[x, y-1].flag
                descobre_celulas_vizinhas_sem_mina(x, y - 1)
            elsif @tabuleiro[x, y-1].valor != '#' && !@tabuleiro[x, y-1].descoberta && !@tabuleiro[x, y-1].flag
				@tabuleiro[x, y-1].descoberta = true
			end
        end
        #célula direita
        if y < @width - 1
            if @tabuleiro[x, y+1].valor == ' ' && !@tabuleiro[x, y+1].descoberta && !@tabuleiro[x, y+1].flag
                descobre_celulas_vizinhas_sem_mina(x, y + 1)
            elsif @tabuleiro[x, y+1].valor != '#' && !@tabuleiro[x, y+1].descoberta && !@tabuleiro[x, y+1].flag
				@tabuleiro[x, y+1].descoberta = true
			end
        end
        #canto esquerdo inferior
        if x < @height - 1 && y > 0
            if @tabuleiro[x+1, y-1].valor == ' ' && !@tabuleiro[x+1, y-1].descoberta && !@tabuleiro[x+1, y-1].flag
                descobre_celulas_vizinhas_sem_mina(x + 1, y - 1)
            elsif @tabuleiro[x+1, y-1].valor != '#' && !@tabuleiro[x+1, y-1].descoberta && !@tabuleiro[x+1, y-1].flag
				@tabuleiro[x+1, y-1].descoberta = true
			end
        end
        #célula inferior
        if x < @height - 1
            if @tabuleiro[x+1, y].valor == ' ' && !@tabuleiro[x+1, y].descoberta && !@tabuleiro[x+1, y].flag
                descobre_celulas_vizinhas_sem_mina(x + 1, y)
            elsif @tabuleiro[x+1, y].valor != '#' && !@tabuleiro[x+1, y].descoberta && !@tabuleiro[x+1, y].flag
				@tabuleiro[x+1, y].descoberta = true
			end
        end
        #canto direito inferior
        if x < @height - 1 && y < @width - 1
            if @tabuleiro[x+1, y+1].valor == ' ' && !@tabuleiro[x+1, y+1].descoberta && !@tabuleiro[x+1, y+1].flag
                descobre_celulas_vizinhas_sem_mina(x + 1, y + 1)
            elsif @tabuleiro[x+1, y+1].valor != '#' && !@tabuleiro[x+1, y+1].descoberta && !@tabuleiro[x+1, y+1].flag
				@tabuleiro[x+1, y+1].descoberta = true
			end
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


begin
	puts "MINE SWEEPER\n\n"
    puts "Digite a largura, altura e número de minas do tabuleiro: "
    input = scanf("%d %d %d")
    game = Minesweeper.new(input[0], input[1], input[2])
    game.preenche_tabuleiro
    SimplePrinter.new.print(game.tabuleiro)

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
		Gem.win_platform? ? (system "cls") : (system "clear")
        if valid_move or valid_flag
			puts "MINE SWEEPER\n\n"
            printer = SimplePrinter.new
            printer.print(game.board_state)
        end
		puts "\nControle: "
		SimplePrinter.new.print(game.tabuleiro)
    end
    
    puts "Fim do jogo!"
    if game.victory?
        puts "Você venceu!"
    else
        puts "Você perdeu! As minas eram:"
        SimplePrinter.new.print(game.board_state(true))
    end
rescue SystemExit

rescue Exception => e
	puts e.message
	puts e.backtrace.inspect
	
    puts "Algum erro ocorreu. Reiniciando jogo: "
    retry
end
