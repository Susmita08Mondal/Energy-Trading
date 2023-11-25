import numpy as np

# Total Utility - Total Cost function
def value_function(x):
    return -(0.0025 * x[0]**2 + 0.0025 * x[1]**2 + 0.005 * x[2]**2 - 0.15 * x[2] + 0.005 * x[3]**2 - 0.15 * x[3])

# Objective function
def objective_function(x, lambda_values):
    return 0.0025 * x[0]**2 + 0.0025 * x[1]**2 + 0.005 * x[2]**2 - 0.15 * x[2] + 0.005 * x[3]**2 - 0.15 * x[3] \
           + np.dot(lambda_values, [x[3] + x[2] - x[1] - x[0], 0.5 - x[0], 0.5 - x[1], 2 - x[2], 2 - x[3], x[0] - 12, x[1] - 12, x[2] - 15, x[3] - 15])

# Gradient of the objective function
def gradient(x):
    return np.array([0.0025 * 2 * x[0], 0.0025 * 2 * x[1], 0.005 * 2 * x[2] - 0.15, 0.005 * 2 * x[3] - 0.15])

# Gradient of the Lagrangian function
def lagrangian_gradient(x, lambda_values):
    grad_objective = gradient(x)
    penalties = [x[3] + x[2] - x[1] - x[0], 0.5 - x[0], 0.5 - x[1], 2 - x[2], 2 - x[3], x[0] - 12, x[1] - 12, x[2] - 15, x[3] - 15]
    grad_constraints=np.zeros(13)
    grad_constraints[4:] += np.array(penalties)
    grad_constraints[:4] += np.array([-lambda_values[0], -lambda_values[0], lambda_values[0], lambda_values[0] ])
    grad_constraints[0] += (lambda_values[5]-lambda_values[1])
    grad_constraints[1] += (lambda_values[6]-lambda_values[2])
    grad_constraints[2] += (lambda_values[7]-lambda_values[3])
    grad_constraints[3] += (lambda_values[8]-lambda_values[4])
    grad_x = grad_objective + grad_constraints[:4]
    grad_lambdas = grad_constraints[4:]    
    return grad_x, grad_lambdas

# Subgradient method with Lagrangian relaxation
def lagrangian_subgradient_method(x0, lambda0, learning_rate, iterations):
    x = x0.copy()
    lambda_values = lambda0.copy()

    for i in range(iterations):
        grad_x, grad_lambdas = lagrangian_gradient(x, lambda_values)
        # print("Grad_x",grad_x)
        # print("Grad_lambdas",grad_lambdas)
        # print("X",x)
        # Update x using the subgradient
        x = x - learning_rate * grad_x[:4]

        # Project x onto the feasible set defined by the constraints
        x[0] = max(0.5, x[0])
        x[1] = max(0.5, x[1])
        x[2] = max(2, x[2])
        x[3] = max(2, x[3])
        x[0] = min(12, x[0])
        x[1] = min(12, x[1])
        x[2] = min(15, x[2])
        x[3] = min(15, x[3])

        # Find all penalties
        penalties = [x[3] + x[2] - x[1] - x[0], 0.5 - x[0], 0.5 - x[1], 2 - x[2], 2 - x[3], x[0] - 12, x[1] - 12, x[2] - 15, x[3] - 15]

        # Update Lagrange multipliers
        lambda_values[0] = lambda_values[0] + learning_rate * lambda_values[0] * (penalties[0])
        lambda_values[1:] = lambda_values[1:] - learning_rate * np.maximum(0,penalties[1:])**2
        
        if(np.linalg.norm(grad_x)< 10**-4):
            print("Grad_x", i,grad_x)
            print("Breaking...")
            return x, grad_lambdas
    return x, lambda_values

# Initial guess
x0 = np.array([5, 5, 5, 5])
lambda0 = np.ones(9)

# Learning rate
learning_rate = 0.5

# Number of iterations
iterations = 10000

# Run lagrangian subgradient method
result, lagrange_multipliers = lagrangian_subgradient_method(x0, lambda0, learning_rate, iterations)

print("Optimal solution:", result)
print("Lagrange multipliers:", lagrange_multipliers)
print("Optimal value of the Lagrangian function:", objective_function(result, lagrange_multipliers))
print("Optimal maximized value of the Value function:", value_function(result))
