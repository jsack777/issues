defmodule CliTest do
  use ExUnit.Case

  import Issues.CLI, only: [parse_args: 1,
                            sort_ascending: 1,
                            convert_to_hashdicts: 1]

  test ":help returned by option parsing -h and --help" do
    assert parse_args(["-h",     "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "3 values returned if given" do
    assert parse_args(["user", "project", "99"]) == {"user", "project", 99}
  end

  test "returns default count if none provided" do
    assert parse_args(["user", "project"]) == {"user", "project", 4}
  end

  test "sort ascending correctly" do
    result = sort_ascending(fake_list(["c", "a", "b"]))
    issues = for issue <- result, do: issue["created_at"]
    assert issues == ~w{a b c}
  end

  defp fake_list(values) do
    data = for value <- values,
           do: [{"created_at", value}, {"other_data", "xxx"}]
    convert_to_hashdicts(data)
  end
end
