"
My instances are the exceptions thrown by the DASTInterpreter during the evaluation process.
If I'm signaled, the interpreter evaluation should pause
"
Class {
	#name : #DASTException,
	#superclass : #Object,
	#instVars : [
		'messageText'
	],
	#category : 'DebuggableASTInterpreter-Exceptions'
}
