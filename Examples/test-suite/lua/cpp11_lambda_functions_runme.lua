local v=require("cpp11_lambda_functions")

function check(received, expected)
    assert(expected == received,
        "check failed, expected: " .. expected .. " received: " .. received)
end

check(v.runLambda1(), 11)
check(v.runLambda2(), 11)
check(v.runLambda3(), 11)
check(v.runLambda4(), 11)
check(v.runLambda5(), 1)
check(v.runLambda5(), 2)
