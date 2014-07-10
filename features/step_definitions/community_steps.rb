Given /^the community server has the cookbooks?:$/ do |table|
  table.raw.each do |name, version, category|
    version  ||= '0.0.0'
    category ||= 'Other'

    CommunityZero::RSpec.store.add(CommunityZero::Cookbook.new(
      name:     name,
      version:  version,
      category: category,
    ))
  end
end

Then /^the community server will( not)? have the cookbooks?:$/ do |negate, table|
  table.raw.each do |name, version, category|
    cookbook = CommunityZero::RSpec.store.find(name, version)

    if negate
      expect(cookbook).to be_nil
    else
      expect(cookbook).to_not be_nil
      expect(cookbook.category).to eql(category) if category
    end
  end
end
