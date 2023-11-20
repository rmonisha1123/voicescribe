# typed: true
# frozen_string_literal: true

require "set"
require "cache_store"

#
# {DescriptionCacheStore} provides methods to fetch and mutate formula descriptions used
# by the `brew desc` and `brew search` commands.
#
class DescriptionCacheStore < CacheStore
  # Inserts a formula description into the cache if it does not exist or
  # updates the formula description if it does exist.
  #
  # @param formula_name [String] the name of the formula to set
  # @param description  [String] the description from the formula to set
  # @return [nil]
  def update!(formula_name, description)
    database.set(formula_name, description)
  end

  # Delete the formula description from the {DescriptionCacheStore}.
  #
  # @param formula_name [String] the name of the formula to delete
  # @return [nil]
  def delete!(formula_name)
    database.delete(formula_name)
  end

  # If the database is empty `update!` it with all known formulae.
  #
  # @return [nil]
  def populate_if_empty!(eval_all: Homebrew::EnvConfig.eval_all?)
    return unless eval_all
    return unless database.empty?

    Formula.all(eval_all: eval_all).each { |f| update!(f.full_name, f.desc) }
  end

  # Use an update report to update the {DescriptionCacheStore}.
  #
  # @param report [Report] an update report generated by cmd/update.rb
  # @return [nil]
  def update_from_report!(report)
    return unless Homebrew::EnvConfig.eval_all?
    return populate_if_empty! if database.empty?
    return if report.empty?

    renamings   = report.select_formula_or_cask(:R)
    alterations = report.select_formula_or_cask(:A) +
                  report.select_formula_or_cask(:M) +
                  renamings.map(&:last)

    update_from_formula_names!(alterations)
    delete_from_formula_names!(report.select_formula_or_cask(:D) +
                               renamings.map(&:first))
  end

  # Use an array of formula names to update the {DescriptionCacheStore}.
  #
  # @param formula_names [Array] the formulae to update
  # @return [nil]
  def update_from_formula_names!(formula_names)
    return unless Homebrew::EnvConfig.eval_all?
    return populate_if_empty! if database.empty?

    formula_names.each do |name|
      update!(name, Formula[name].desc)
    rescue FormulaUnavailableError, *FormulaVersions::IGNORED_EXCEPTIONS
      delete!(name)
    end
  end

  # Use an array of formula names to delete them from the {DescriptionCacheStore}.
  #
  # @param formula_names [Array] the formulae to delete
  # @return [nil]
  def delete_from_formula_names!(formula_names)
    return if database.empty?

    formula_names.each(&method(:delete!))
  end
  alias delete_from_cask_tokens! delete_from_formula_names!

  # `select` from the underlying database.
  def select(&block)
    database.select(&block)
  end
end

#
# {CaskDescriptionCacheStore} provides methods to fetch and mutate cask descriptions used
# by the `brew desc` and `brew search` commands.
#
class CaskDescriptionCacheStore < DescriptionCacheStore
  # If the database is empty `update!` it with all known casks.
  #
  # @return [nil]
  def populate_if_empty!(eval_all: Homebrew::EnvConfig.eval_all?)
    return unless eval_all
    return unless database.empty?

    Cask::Cask.all.each { |c| update!(c.full_name, [c.name.join(", "), c.desc.presence]) }
  end

  # Use an update report to update the {CaskDescriptionCacheStore}.
  #
  # @param report [Report] an update report generated by cmd/update.rb
  # @return [nil]
  def update_from_report!(report)
    return unless Homebrew::EnvConfig.eval_all?
    return populate_if_empty! if database.empty?
    return if report.empty?

    alterations = report.select_formula_or_cask(:AC) +
                  report.select_formula_or_cask(:MC)

    update_from_cask_tokens!(alterations)
    delete_from_cask_tokens!(report.select_formula_or_cask(:DC))
  end

  # Use an array of cask tokens to update the {CaskDescriptionCacheStore}.
  #
  # @param cask_tokens [Array] the casks to update
  # @return [nil]
  def update_from_cask_tokens!(cask_tokens)
    return unless Homebrew::EnvConfig.eval_all?
    return populate_if_empty! if database.empty?

    cask_tokens.each do |token|
      c = Cask::CaskLoader.load(token)
      update!(c.full_name, [c.name.join(", "), c.desc.presence])
    rescue Cask::CaskUnavailableError, *FormulaVersions::IGNORED_EXCEPTIONS
      delete!(c.full_name) if c.present?
    end
  end
end
