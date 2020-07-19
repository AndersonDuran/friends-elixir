defmodule FriendsApp.CLI.Menu.Choice do
  alias Mix.Shell.IO, as: Shell
  alias FriendsApp.CLI.Menu.Itens
  alias FriendsApp.DB.CSV

  def start do
    Shell.cmd("clear")
    Shell.info("Escolha uma opção:")

    menu_itens = Itens.all()

    #Declarando uma função e fazendo bind - &1 representa argumento 1
    find_menu_item_by_index = &Enum.at(menu_itens, &1, :error)

    #Sequencia de pipe operator
    #Cadeia de operações em cima do menu_items

    menu_itens
    |> Enum.map(&(&1.label))  #Dentro do map: função anônima, pegando o argumento 1 e chamando label
    |> display_options()
    |> generate_question()
    |> Shell.prompt()
    |> parse_answer()
    |> find_menu_item_by_index.()
    |> confirm_choice()
    |> confirm_message()
    |> CSV.perform()
  end

  defp display_options(options) do
    options
    |> Enum.with_index(1) #Enumerando os itens com indice e offset '1' [a:1, b:2]
    |> Enum.each(fn {option, index} ->
      Shell.info("#{index} - #{option}")
    end)

    options
  end

  defp generate_question(options) do
    options = Enum.join(1..Enum.count(options), ",")
    "Selecione uma opção: [#{options}]\n"
  end

  defp parse_answer(answer) do
    case Integer.parse(answer) do
     :error -> invalid_option()
     {option, _} -> option - 1
    end
  end

  defp confirm_choice(chosen_item) do
    case chosen_item do
      :error -> invalid_option()
      _ -> chosen_item
    end
  end

  defp confirm_message(chosen_item) do
    Shell.cmd("clear")
    Shell.info("Você escolheu '#{chosen_item.label}'")

    if Shell.yes?("Confirma escolha?") do
      chosen_item
    else
      start()
    end
  end


  defp invalid_option() do
    Shell.cmd("clear")
    Shell.error("Opção inválida!")
    Shell.prompt("Pressione uma tecla para continuar...")
    start()
  end
end
