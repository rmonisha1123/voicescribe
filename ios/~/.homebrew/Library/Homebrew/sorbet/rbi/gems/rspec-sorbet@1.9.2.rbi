# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `rspec-sorbet` gem.
# Please instead update this file by running `bin/tapioca gem rspec-sorbet`.

module RSpec
  extend ::RSpec::Support::Warnings
  extend ::RSpec::Core::Warnings

  class << self
    def clear_examples; end
    def configuration; end
    def configuration=(_arg0); end
    def configure; end
    def const_missing(name); end
    def context(*args, &example_group_block); end
    def current_example; end
    def current_example=(example); end
    def current_scope; end
    def current_scope=(scope); end
    def describe(*args, &example_group_block); end
    def example_group(*args, &example_group_block); end
    def fcontext(*args, &example_group_block); end
    def fdescribe(*args, &example_group_block); end
    def reset; end
    def shared_context(name, *args, &block); end
    def shared_examples(name, *args, &block); end
    def shared_examples_for(name, *args, &block); end
    def world; end
    def world=(_arg0); end
    def xcontext(*args, &example_group_block); end
    def xdescribe(*args, &example_group_block); end
  end
end

RSpec::MODULES_TO_AUTOLOAD = T.let(T.unsafe(nil), Hash)
RSpec::SharedContext = RSpec::Core::SharedContext

module RSpec::Sorbet
  extend ::RSpec::Sorbet::Doubles
end

module RSpec::Sorbet::Doubles
  requires_ancestor { Kernel }

  sig { void }
  def allow_doubles!; end

  def allow_instance_doubles!(*args, &blk); end

  sig { params(clear_existing: T::Boolean).void }
  def reset!(clear_existing: T.unsafe(nil)); end

  private

  sig { params(signature: T.untyped, opts: T::Hash[T.untyped, T.untyped]).void }
  def call_validation_error_handler(signature, opts); end

  sig { returns(T.nilable(T::Boolean)) }
  def configured; end

  def configured=(_arg0); end

  sig { params(message: ::String).returns(T::Boolean) }
  def double_message_with_ellipsis?(message); end

  sig { returns(T.nilable(T.proc.params(signature: T.untyped, opts: T::Hash[T.untyped, T.untyped]).void)) }
  def existing_call_validation_error_handler; end

  def existing_call_validation_error_handler=(_arg0); end

  sig { returns(T.nilable(T.proc.params(signature: ::Exception).void)) }
  def existing_inline_type_error_handler; end

  def existing_inline_type_error_handler=(_arg0); end

  sig { params(signature: T.untyped, opts: T.untyped).void }
  def handle_call_validation_error(signature, opts); end

  sig { params(error: ::Exception).void }
  def inline_type_error_handler(error); end

  sig { params(message: ::String).returns(T::Boolean) }
  def typed_array_message?(message); end

  sig { params(message: ::String).returns(T::Boolean) }
  def unable_to_check_type_for_message?(message); end
end

RSpec::Sorbet::Doubles::INLINE_DOUBLE_REGEX = T.let(T.unsafe(nil), Regexp)
RSpec::Sorbet::Doubles::TYPED_ARRAY_MESSAGE = T.let(T.unsafe(nil), Regexp)
RSpec::Sorbet::Doubles::VERIFYING_DOUBLE_OR_DOUBLE = T.let(T.unsafe(nil), Regexp)
