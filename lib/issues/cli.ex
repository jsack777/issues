defmodule Issues.CLI do

  @default_count 4

  @moduledoc """
  Handle the command line parsing
  """

  def run(argv) do
    argv
     |> parse_args
     |> process
  end

  @doc """
  'argv' can be -h or --help
  otherwise it is a github user name, project name, and 3 entries
  """

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    case parse do
      {[help: true], _, _} -> :help

      {_, [user, project, count], _} ->
        { user, project, String.to_integer(count) }

      {_, [user, project], _} ->
        { user, project, @default_count}

      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> convert_to_hashdicts
    |> sort_ascending
    |> Enum.take(count)
  end

  def decode_response({ :ok, body }), do: body

  def decode_response({ :error, error }) do
    {_, message} = List.keyfind(error, "message", 0)
    IO.puts "Error fetching from github: #{message}"
    System.halt(2)
  end

  def convert_to_hashdicts(list) do
    list
    |> Enum.map(&Enum.into(&1, HashDict.new))
  end

  def sort_ascending(issue_list) do
    Enum.sort issue_list, fn i1, i2 ->
        i1["created_at"] <= i2["created_at"]
      end
  end
end
