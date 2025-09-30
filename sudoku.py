
#sudoku is 9x9 grid of int (0=empty)
import time


class csp():
    #constructor variables initail puzzle state is passed in
    def __init__(self, variables):
        self.variables = [(i,j) for i in range(9) for j in range(9)]
        self.domains = self.makeDomains(variables)
        self.constraints = {}
        self.makeConstraints(self.variables)

    #makes domains for each variable stored as dictionary
    #for variables that dont have an initial assignment a list of 1-9 is given
    #else domain is set to [assignment]
    def makeDomains(self, variables):
        domains = {}
        for x in range(9):
            for y in range(9):
                if variables[x][y] != 0:
                    domains[(x,y)] = [variables[x][y]]
                else:
                    domains[(x,y)] = [i for i in range(1,10)]
        
        return domains
    
    #makes constaraints for each value stored in dictionary
    def makeConstraints(self, variables):
        for var in variables:
            constraint = []
            for i in range(9):
                #rows cant equal
                if i != var[0]:
                    constraint.append((i, var[1]))
                #columns cant equal 
                if i != var[1]:
                    constraint.append((var[0], i))
            
            subX, subY = var[0] // 3, var[1] // 3

            for x in range(subX * 3, (subX+1) *3):
                for y in range(subY *3, (subY+1)*3):
                    if (x,y) != var:
                        constraint.append((x,y))
            
            self.constraints[var] = constraint
    
    #select next variable that has not been given an asignment yet
    def selectUnasignedVar(self, assignment):
        unassignedVar = []
        for var in self.variables: 
            if var not in assignment:
                unassignedVar.append(var)
        #set min dom var to first
        curMin = unassignedVar[0]
        for var1 in unassignedVar:
            #return var instantly if domain length 1
            if len(self.domains[var1]) == 1:
                return var1
            #finds min domain var
            else:
                if len(self.domains[var1]) < len(self.domains[var1]):
                    curMin = var1
        return curMin


    #checks if value assigned conforms to teh variables constraints
    def isConsistent(self, var, value, assignment):
        for constraint in self.constraints[var]:
            if constraint in assignment and assignment[constraint] == value:
                return False
        return True

    #gets the pomain value sof a variable
    def orderDomainValues(self, var):
        return self.domains[var]
    
    #starts search 
    def backtrackSearch(self):
        return self.recursiveBacktrack({})

    #does search
    def recursiveBacktrack(self, assignment):
        #checks if every var as been assigned
        if len(assignment) == len(self.variables):
            return assignment
        
        #gets next var
        var = self.selectUnasignedVar(assignment)

        #gets first val that corforms to constraints else returns fail(None) as we want to return a complete puzzel not a success or fail
        for val in self.orderDomainValues(var):
            if self.isConsistent(var, val, assignment):
                assignment[var] = val
                result = self.recursiveBacktrack(assignment)
                if result is not None:
                    return result
                assignment.pop(var)
        return None

#funciton to get puzzle from user line my line
#not required for functionality
def getPuzzle():
    temp = []

    for i in range(9):
        rowVals = []
        row = input(f"values of row {i+1}: ")
        stream = row.split(",")
        for var in stream:
            rowVals.append(int(var))
        
        temp.append(rowVals)
    
    return temp

#print the solution in a nice format
def printSudoku(puzzle):
    for i in range(9):
        if i%3 ==0 and i !=0:
            print("- - - - - - - - - - -")
        for j in range(9):
            if j%3 == 0 and j != 0:
                print("|", end= " ")
            print(puzzle[i][j], end= " ")
        print()


def main():
    #create csp object, passing initial state 

    #problem = csp([[7,0,0,0,9,2,0,5,0],
    #            [0,3,0,1,7,5,6,0,0],
    #            [9,0,1,8,4,0,2,7,0],
    #            [3,7,0,0,5,0,0,1,0],
    #            [5,4,0,9,0,0,7,3,6],
    #            [0,6,0,0,0,0,0,0,5],
    #            [6,2,0,7,0,9,0,4,8],
    #            [8,1,0,0,0,0,9,0,0],
    #            [0,0,7,2,0,0,5,0,1]])
        
    problem = csp([[0,0,0,0,0,0,0,0,0],
                   [0,0,0,0,0,0,0,0,0],
                   [0,0,0,0,0,0,0,0,0],
                   [0,0,0,0,0,0,0,0,0],
                   [0,0,0,0,0,0,0,0,0],
                   [0,0,0,0,0,0,0,0,0],
                   [0,0,0,0,0,0,0,0,0],
                   [0,0,0,0,0,0,0,0,0],
                   [0,0,0,0,0,0,0,0,0]])

    startT = time.perf_counter_ns()

    #run search, returns dictionary
    sol = problem.backtrackSearch()

    endT = time.perf_counter_ns()

    runtime = (endT-startT)/1e6

    #convert to 2D array for easy value access
    #also so that we dont have to destroy the dictionary to get random access
    solution = [[0 for _ in range(9)] for _ in range(9)]
    for (i,j), val in sol.items():
        solution[i][j] = val
    


                
    printSudoku(solution)

    print(f"runtime (ms): {runtime}")


main()