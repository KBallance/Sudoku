import time
import tkinter as tk
import tkinter.font as tkFont
from argparse import ArgumentParser

#class used to implements a "editable" cell label
#handles user events to change the values of the cells
class EditLabel():
    #initiates helper class
    def __init__(self, csp):
       self.currentEdit = None
       self.cspRef = csp
       self.valid = {'1','2','3','4','5','6','7','8','9','BackSpace','Return'}
    
    #changes the current label being edited
    def swapCell(self, event=tk.Event()):
        if self.currentEdit:
            self.stopEdit()
        #gets name of label ("xy") and converts to tuple
        name = event.widget.winfo_name()
        self.currentEdit = (int(name[0]), int(name[1]))
        self.cspRef.cells[self.currentEdit[0]][self.currentEdit[1]].config(bg=hexFromRgb(155,155,155))
    
    #updates the label based on keyboard input
    def edit(self, event=tk.Event()):
        key = event.keysym
        #checks if pressed key is valid
        if key in self.valid:
            #clears cell
            if key == 'BackSpace' and self.currentEdit:
                x,y = self.currentEdit[0],self.currentEdit[1]
                self.cspRef.cellsStrVar[x][y].set("")
                self.cspRef.cells[x][y].config(bg=hexFromRgb(155,155,155))
            #exits edit mode, i.e key presses wont change any cells
            elif key == 'Return':
                self.stopEdit()
            #replace current cell with typed number
            elif self.currentEdit:
                x,y = self.currentEdit[0],self.currentEdit[1]
                self.cspRef.cellsStrVar[x][y].set(key)
                self.cspRef.cells[x][y].config(bg=hexFromRgb(95,95,95))

    #ends edit mode
    #sets current edit cell to none and
    #visible removes cell highlights to show user nothing will get changed
    def stopEdit(self):
        key = self.currentEdit
        cell = self.cspRef.cells[key[0]][key[1]]
        text = cell.cget("text")
        if text == "":
            cell.config(bg=hexFromRgb(120,120,120))
        else:
            cell.config(bg=hexFromRgb(75,75,75))
        self.currentEdit = None


class csp():
    #constructor variables initail puzzle state is passed in
    def __init__(self, variables):
        #debug
        self.calls = {
            "makeDomains": 0,
            "makeConstraints": 0,
            "selectUnasignedVar": 0,
            "isConsistent": 0,
            "orderDomainValues": 0,
            "recursiveBacktrack": 0
        }
        #problem variables
        self.variables = [(i,j) for i in range(9) for j in range(9)]
        self.domains = self.makeDomains(variables)
        self.constraints = self.makeConstraints(self.variables)
        self.solution = None

        #gui Variables
        self.cells = [[0]*9 for _ in range(9)]
        self.cellsStrVar = [[tk.StringVar]*9 for _ in range(9)] #use StringVar to link label text to variable
        self.gui = self.createGui() 

    def createGui(self):
        #adds padding to middle squares (both axis)
        def genPadding(x):
            smallGap, bigGap = 0, 1
            if x == 1:
                return (bigGap, bigGap)
            else:
                return (smallGap, smallGap)

        #helper class used to edit the cell labels
        #used over simple entry widgets as they dont look very nice     
        editManager = EditLabel(self)

        #window init
        root = tk.Tk()
        root.resizable(False, False)
        root.title("Sudoku Solver")
        mainWindow = tk.Frame(root, height=120, width=100, bg=hexFromRgb(50,50,50))
        mainWindow.grid(column=0,row=0)

        #heading
        titleFont = tkFont.Font(family="Verdana", size=20, weight="bold")
        title = tk.Label(mainWindow, text="Sudoku Solver", bg=hexFromRgb(50,50,50), height=2, width=15, font=titleFont, foreground="White")
        title.grid(column=1, row=0, columnspan=3)

        #grid init
        sudokuFrame = tk.Frame(mainWindow, bg=hexFromRgb(255,255,255))
        sudokuFrame.grid(column=1, row=1)
        #use sub frames to get around grid padding limitations
        subFrames = [[tk.Frame]*3 for _ in range(3)]
        for x in range(len(subFrames)):
            for y in range(len(subFrames)):
                #sub frame init
                subFrames[x][y] = tk.Frame(sudokuFrame, bg=hexFromRgb(255,255,255))
                subFrames[x][y].grid(row=x, column=y, padx=genPadding(x), pady=genPadding(y))

        #add cells to grid
        cellFont = tkFont.Font(family="Verdana", size=12, weight="bold")
        for i in range(9):
            for j in range(9):
                #cell init
                self.cellsStrVar[i][j] = tk.StringVar(mainWindow)
                self.cells[i][j] = tk.Label(subFrames[i//3][j//3], name=f"{i}{j}", bg=hexFromRgb(120,120,120), width=5, height=2, cursor="ibeam" ,foreground="white", anchor="center", font=cellFont, textvariable=self.cellsStrVar[i][j])
                self.cells[i][j].bind("<Button-1>", editManager.swapCell)
                self.cells[i][j].grid(row=i, column=j, padx=1, pady=1)
                
                #set cell value if input cell != 0
                if len(self.domains[i,j]) == 1:
                    self.cells[i][j].config(bg=hexFromRgb(75,75,75))
                    self.cellsStrVar[i][j].set(f"{self.domains[i,j][0]}")
        
        #add event for click
        root.bind("<Key>", editManager.edit)
        
        #button frame init
        buttonFrame = tk.Frame(mainWindow, bg=hexFromRgb(50,50,50), height = 4)
        buttonFrame.grid(row=3, column=1, columnspan = 3)

        #solve btn
        solveButton = tk.Button(buttonFrame, bg=hexFromRgb(180,180,180), relief="ridge", text="Solve Puzzle", font=cellFont, fg = hexFromRgb(25,25,25), height=2, width=12, command=self.showSolve)
        solveButton.grid(row=1, column=1, columnspan=1, pady=2, padx=2)
        
        #clear btn
        clearButton = tk.Button(buttonFrame, bg=hexFromRgb(180,180,180), relief="ridge", text="Clear Puzzle", font=cellFont, fg = hexFromRgb(25,25,25), height=2, width=12, command=self.clearPuzzle)
        clearButton.grid(row=1, column=2, columnspan=1, pady=2, padx=2)

        return root

    #solve puzzle and show on gui
    def showSolve(self):
        if args.gui: self.clearCalls()

        #solve & track time taken
        startT = time.perf_counter_ns()
        self.solution = self.backtrackSearch()
        runtime = (time.perf_counter_ns()-startT)/1e6

        #skip rest if no solution was found
        if self.solution is None:
            print("No solution")
            return

        #update gui cells
        if args.gui:
            for (i,j), val in self.solution.items():
                self.cellsStrVar[i][j].set(str(val))
        
        #debug
        if not args.gui or args.debug: self.printSudoku(self.solution)
        if args.debug:
            print(f"runtime: {runtime}ms")
            self.printCalls()
    
    #clear gui cells
    def clearPuzzle(self):
        for i in range(9):
            for j in range(9):
                if self.cells[i][j].cget("bg") != hexFromRgb(75,75,75):
                    self.cellsStrVar[i][j].set('')
    
    #wrapper fun for tkinter mainloop
    def showGui(self):
        self.gui.mainloop()

    #prints some debug data on number of function calls
    def printCalls(self):
        for k,v in self.calls.items():
            print(f"{k}: {v}")
    
    #prints puzzle in terminal
    def printSudoku(self, puzzle):
        for i in range(9):
            if i%3 ==0 and i !=0:
                print("──────┼───────┼──────")
            for j in range(9):
                if j%3 == 0 and j != 0:
                    print("│", end= " ")
                print(puzzle[i,j], end= " ")
            print()

    #makes domains for each variable stored as dictionary
    #for variables that dont have an initial assignment a list of 1-9 is given
    #else domain is set to {assignment}
    def updateDomains(self):
        for i in range(9):
            for j in range(9):
                t = self.cellsStrVar[i][j].get()
                if t == '':
                    self.domains[i,j] =  {1,2,3,4,5,6,7,8,9}
                else:
                    self.domains[i,j] = {int(t)}
    
    #clears call values between solves
    def clearCalls(self):
        for k in self.calls.keys():
            self.calls[k] = 0

    #make domains from inital puzzle
    def makeDomains(self, values):
        self.calls["makeDomains"] += 1
        domains = {}
        for x in range(9):
            for y in range(9):
                if values[x][y] != 0:
                    domains[(x,y)] = [values[x][y]]
                else:
                    domains[(x,y)] = [*range(1,10)]
        return domains
    
    #makes constraints for each value stored in dictionary
    def makeConstraints(self, values):
        self.calls["makeConstraints"] += 1
        constraints = {}
        for var in values:
            constraint = []
            for i in range(9):
                #rows cant equal
                if i != var[0]:
                    constraint.append((i, var[1]))
                #columns cant equal 
                if i != var[1]:
                    constraint.append((var[0], i))
            
            subX, subY = var[0] // 3, var[1] // 3

            for x in range(subX * 3, (subX + 1) * 3):
                for y in range(subY * 3, (subY + 1) * 3):
                    if (x,y) != var:
                        constraint.append((x,y))
            
            constraints[var] = constraint
        return constraints
    
    #select next variable that has not been given an asignment yet
    def selectUnassignedVar(self, assignment):
        self.calls["selectUnasignedVar"] += 1
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
                if len(self.domains[var1]) < len(self.domains[curMin]):
                    curMin = var1
        return curMin

    #checks if value assigned conforms to teh variables constraints
    def isConsistent(self, var, value, assignment):
        self.calls["isConsistent"] += 1
        for constraint in self.constraints[var]:
            if constraint in assignment and assignment[constraint] == value:
                return False
        return True

    #gets the pomain value sof a variable
    def orderDomainValues(self, var):
        self.calls["orderDomainValues"] += 1
        return self.domains[var]
    
    #starts search 
    def backtrackSearch(self):
        self.updateDomains()
        return self.recursiveBacktrack({})
    

    #update domains dynamically for forward checking
    def removeDom(self, var, val):
        for constraint in self.constraints[var]:
            self.domains[constraint] = self.domains[constraint] - {val}
    
    def addDom(self, var, val):
        for constraint in self.constraints[var]:
            self.domains[constraint] = self.domains[constraint] | {val}

    #does search
    def recursiveBacktrack(self, assignment):
        self.calls["recursiveBacktrack"] += 1
        #checks if every var as been assigned
        if len(assignment) == len(self.variables):
            return assignment
        
        #gets next var
        var = self.selectUnassignedVar(assignment)

        #gets first val that conforms to constraints else returns fail(None) as we want to return a complete puzzle not a success or fail
        for val in self.orderDomainValues(var):
            if self.isConsistent(var, val, assignment):
                assignment[var] = val
                self.removeDom(var,val)
                result = self.recursiveBacktrack(assignment)
                if result is not None:
                    return result
                assignment.pop(var)
                self.addDom(var, val)
        return None

#converts rgb value to hexcode
def hexFromRgb(r,g,b):
    return f'#{r:02x}{g:02x}{b:02x}'

#check file arg is .txt or .csv (case insensitive)
def isFileType(string:str):
    try:
        s = string.rsplit(".", 1)[1].lower()
        if len(s) > 0 and s in ["txt", "csv"]:
            return string
        else:
            raise TypeError
    except:
        raise

#create parser for command line args
parser = ArgumentParser(
    prog="Sudoku Solver",
    description="Solves a 9x9 sudoku puzzle using backtrack search with forward checking"
)
parser.add_argument(#positional (required)
    "filename",
    type=isFileType,
    help="File path to .txt or .csv file containing 9x9 puzzle."
)
parser.add_argument(#flag (optional)
    "-d", "--debug",
    action="store_true",
    help="Print debug output to terminal."
)
parser.add_argument(#flag (optional)
    "-g", "--gui",
    action="store_true",
    help="Show graphical interface."
)

#read txt/csv into csp
def readPuzzle(filename):
    fileType = filename[-3:].lower()
    vars = []

    #open file & convert contents into 2d array
    with open(filename, "r") as file:
        if fileType == "txt":
            vars = [[int(v) for v in line.strip().split(" ")] for line in file.readlines()]
        elif fileType == "csv":
            vars = [[int(v) for v in line.strip(" ,\n\r\t\f").split(",")] for line in file.readlines()]
        else:
            raise Exception("Invalid file type?")
    
    #check puzzle has valid no. cells
    if [len(x) for x in vars].count(9) != 9:
        raise Exception("Invalid puzzle.")

    return csp(vars)

#runs only if file directly run (not imported by another file)
if __name__ == "__main__":
    args = parser.parse_args() #get args from command line (uses sys package by default)

    problem = readPuzzle(args.filename)
    if args.gui:
        problem.showGui()
    else:
        problem.showSolve()