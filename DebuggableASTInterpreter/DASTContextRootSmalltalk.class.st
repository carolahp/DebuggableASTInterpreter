"
I'm the first context, the one who accesses global variables. 
I must be refactored when contexts start to use DASTEnvironments
"
Class {
	#name : #DASTContextRootSmalltalk,
	#superclass : #DASTContext,
	#category : #'DebuggableASTInterpreter-Contexts'
}

{ #category : #accessing }
DASTContextRootSmalltalk >> findVariable: aByteSymbol [

	^ Smalltalk globals at: aByteSymbol ifAbsent: [ 
		self error: 'Variable ', aByteSymbol , ' not defined!'
		 ]
]

{ #category : #'gt-extension' }
DASTContextRootSmalltalk >> gtInspectorSourceIn: composite [
	<gtInspectorPresentationOrder: 30> 
	''
]

{ #category : #accessing }
DASTContextRootSmalltalk >> isBlockContext [
	^false
]

{ #category : #accessing }
DASTContextRootSmalltalk >> isRoot [ 
	^true
]

{ #category : #accessing }
DASTContextRootSmalltalk >> isUnwindContext [
	"is this context for  method that is marked?"
	^ self shouldNotImplement 
]
