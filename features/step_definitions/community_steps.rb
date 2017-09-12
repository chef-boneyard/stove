Given /^the supermarket has the cookbooks?:$/ do |table|
  table.raw.each do |name, version|
    version  ||= '0.0.0'

    CommunityZero::RSpec.store.add(CommunityZero::Cookbook.new(
      name:     name,
      version:  version,
      category: 'Other',
    ))
  end
end

Then /^the supermarket will( not)? have the cookbooks?:$/ do |negate, table|
  table.raw.each do |name, version|
    cookbook = CommunityZero::RSpec.store.find(name, version)

    if negate
      expect(cookbook).to be_nil
    else
      expect(cookbook).to_not be_nil
    end
  end
end
