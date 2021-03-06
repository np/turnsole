module Turnsole

## simple class to capture tagging of things and applying actions to them
class Tagger
  def initialize context, mode, noun="thread", plural_noun=nil
    @context = context
    @mode = mode
    @noun = noun
    @tagged = Set.new
    @plural_noun = plural_noun || (@noun + "s")
  end

  def tagged? o; @tagged.member?(o) end
  def tag o; @tagged << o end
  def untag o; @tagged.delete o end
  def toggle o; tagged?(o) ? untag(o) : tag(o) end
  def drop_all_tags!; @tagged.clear end

  def apply_to_tagged! action=nil
    num_tagged = @tagged.size
    if num_tagged == 0
      @context.screen.minibuf.flash "No tagged #{@plural_noun}!"
      return
    end

    noun = num_tagged == 1 ? @noun : @plural_noun

    if action.nil?
      c = @context.input.ask_getch "apply to #{num_tagged} tagged #{noun}:"
      return if c.nil? # user cancelled
      action = @context.input.resolve_input_on_mode @mode, c
    end

    if action
      tagged_sym = "multi_#{action}".intern
      if @mode.respond_to? tagged_sym
        @mode.send tagged_sym, @tagged
      else
        @context.screen.minibuf.flash "That command cannot be applied to multiple #{@plural_noun}."
      end
    else
      @context.screen.minibuf.flash "Unknown command #{c.to_character}."
    end
  end
end

end
