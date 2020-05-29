local pumpjack = data.raw["mining-drill"]["pumpjack"]

local resource_categories = {}

for i, resource_category in ipairs(pumpjack.resource_categories) do
  resource_categories[resource_category] = true
end

local resource_entities = Oil_Patches_Organizer.resource_entities

for resource_name, resource in pairs(data.raw["resource"]) do
  if resource_categories[resource.category] then
    resource_entities[#resource_entities + 1] = resource_name
  end
end

if #resource_entities == 0 then
  error('Unable to continue, could not find any resources to arrange.')
end

-- to trigger error for non-resource entity
--resource_entities[#resource_entities + 1] = 'offshore-pump'

log('found the following resources to organize:')
for i,resource_name in ipairs(resource_entities) do
  log(resource_name)
end
