#@variable(m, x )              # No bounds
#@variable(m, x >= lb )        # Lower bound only
#@variable(m, x <= ub )        # Upper bound only
#@variable(m, x == fixedval )  # Fixed to a value (lb == ub)

function calVarDict(varKey, label, nowLength)
  global varLength = varLength + nowLength
  varStartValue[varKey] = varStartLength
  varEndValue[varKey] = varLength
  varGroup[varKey] = label
  global varStartLength = varStartLength + nowLength
end

macro solveDEA_varibleInit(model)
  global varLength = 0
  global varStartLength = 1
  global varibleInitFlag = true
  global varStartValue = Dict()
  global varEndValue = Dict()
  global varGroup = Dict()
  global varSolution = Dict()
end

macro solveDEA_varible(m, xInequality, label)
  if xInequality.args[2] == :(>=) # Lower bound only
    tmpStr = string(xInequality.args[1])
    if contains(tmpStr, ":")
      start = search(tmpStr, '[')
      mid = search(tmpStr, ':')
      End = search(tmpStr, ']')
      scale = parse(Int32, tmpStr[mid+1:End-1])
      varStr = tmpStr[1:start-1]
      calVarDict(string(varStr), string(label), scale)
      quote
        @variable($m, $xInequality)
      end
    else
      calVarDict(string(tmpStr), string(label), 1)
      quote
        @variable($m, $xInequality)
      end
    end
  elseif xInequality.args[2] == :(<=) # Lower bound only or Lower and upper bounds
    tmpStr = string(xInequality.args[1])
    if contains(tmpStr, ":")
      start = search(tmpStr, '[')
      mid = search(tmpStr, ':')
      End = search(tmpStr, ']')
      scale = parse(Int32, tmpStr[mid+1:End-1])
      varStr = tmpStr[1:start-1]
      calVarDict(string(varStr), string(label), scale)
      quote
        @variable($m, $xInequality)
      end
    else
      calVarDict(string(tmpStr), string(label), 1)
      quote
        @variable($m, $xInequality)
      end
    end
  elseif xInequality.args[2] == :(==) # No bounds
    tmpStr = string(xInequality.args[1])
    if contains(tmpStr, ":")
      start = search(tmpStr, '[')
      mid = search(tmpStr, ':')
      End = search(tmpStr, ']')
      scale = parse(Int32, tmpStr[mid+1:End-1])
      varStr = tmpStr[1:start-1]
      calVarDict(string(varStr), string(label), scale)
      quote
        @variable($m, $xInequality)
      end
    else
      calVarLength(1)
      calVarDict(string(tmpStr), string(label), 1)
      quote
        @variable($m, $xInequality)
      end
    end
  else # No bounds
    tmpStr = string(xInequality.args[1])
    if contains(tmpStr, ":")
      start = search(tmpStr, '[')
      mid = search(tmpStr, ':')
      End = search(tmpStr, ']')
      scale = parse(Int32, tmpStr[mid+1:End-1])
      varStr = tmpStr[1:start-1]
      calVarDict(string(varStr), string(label), scale)
      quote
        @variable($m, $xInequality)
      end
    else
      calVarLength(1)
      calVarDict(string(tmpStr), string(label), 1)
      quote
        @variable($m, $xInequality)
      end
    end
  end
end
