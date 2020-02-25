Class {
	#name : #DASTInterpreterClassForTests5,
	#superclass : #Object,
	#classVars : [
		'classVar5'
	],
	#classInstVars : [
		'count'
	],
	#category : #'DebuggableASTInterpreter-TestsClasses'
}

{ #category : #'class initialization' }
DASTInterpreterClassForTests5 class >> count [
	^ count
]

{ #category : #'class initialization' }
DASTInterpreterClassForTests5 class >> initialize [ 
	count := 0
]

{ #category : #'class initialization' }
DASTInterpreterClassForTests5 class >> new [
    count := count +1.
    ^ super new
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests5 >> m1 [
	^self m2
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests5 >> m2 [
	^3
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests5 >> m3 [
	^ 4
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests5 >> m4 [
	^ 44
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests5 >> m5 [
	<primitive: 666>
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests5 >> m6 [
	^ self m5
]
