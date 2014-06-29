Given /^the Stove config at "(.+)" is "(.+)"/ do |variable, value|
  Stove::Config.__set__(variable, value)
end

Given /^the Stove config at "(.+)" is unset/ do |variable|
  Stove::Config.__unset__(variable)
end
