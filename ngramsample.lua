if #arg<3 then 
  print [[usage: lua ngramsample.lua file seedlength length'
example: $ lua ngramsample.lua quijote.txt 3 1000 > out.txt ]]
  os.exit(1)
end


local ENDCHAR = nil --'.'
local FILENAME = arg[1] --'quijote.txt'
local SEEDLENGTH = tonumber(arg[2]) --6
local LENGTH = tonumber(arg[3]) --1000
local PURGERETURNS = true

math.randomseed(os.time())

local f = assert(io.open(FILENAME))

local len = f:seek("end")

local find_random = function(fragment)
  local pos=math.random(0, len-#fragment)
  f:seek('set', pos)
  local round, curr
  local buff = f:read(1024)
  local start, fin 
  repeat
    start, fin = buff:find(fragment, 1, true)
    if round and f:seek()>=pos then break end 
    if not fin or fin==#buff then
      f:seek('set', f:seek()-#fragment)
      buff = f:read(1024)
      if #buff<=#fragment then
        f:seek('set', 0)
        buff = f:read(1024)
        round = true
      end
      curr = f:seek()
    end
  until fin and fin<#buff
  if fin then
    return buff:sub(fin+1, fin+1)
  end
end

local ch = find_random('. ')
if not ch then 
  ch = find_random('\n')
end
local seed = ch
for i=1,SEEDLENGTH or 1 do
  ch = find_random(ch)
  seed = seed..ch
end


local length = 0
local out, lseek = seed, #seed
repeat
  for chlen = lseek, 1, -1 do
    ch = find_random(out:sub(-chlen))
    if ch then break end
  end
  out = out..ch
  length=length+1
until not ch or ch==ENDCHAR or (LENGTH and length>=LENGTH)

if PURGERETURNS then 
  out = out:gsub('\n', '')
end
repeat
  local count
  out, count = out:gsub('  ', ' ')
until count==0
  
print(out)

