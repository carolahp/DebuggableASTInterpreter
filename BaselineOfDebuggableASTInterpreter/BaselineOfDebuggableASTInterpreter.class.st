Class {
	#name : #BaselineOfDebuggableASTInterpreter,
	#superclass : #BaselineOf,
	#category : #BaselineOfDebuggableASTInterpreter
}

{ #category : #baselines }
BaselineOfDebuggableASTInterpreter >> baseline: spec [

	<baseline>
	spec
		for: #common
		do: [
			"Dependencies"
			spec
				baseline: 'SpecDebugger'
				with: [ spec repository: 'github://dupriezt/Spec-Debugger' ].
			spec
				baseline: 'Ghost'
				with: [ spec repository: 'gitlab://gitlab.inria.fr:RMOD/Ghost' ].
				
			"Packages"
			spec
				package: 'DebuggableASTInterpreter';
				package: 'DebuggableASTInterpreterBootstrap' with: [ spec requires: #('DebuggableASTInterpreter') ];
				package: 'DebuggableASTDebuggerBootstrap' with: [ spec requires: #('DebuggableASTInterpreter') ];
				package: 'DebuggableASTDebugger' with: [ spec requires: #('DebuggableASTInterpreter' 'SpecDebugger') ];
				package: 'DebuggableASTInterpreterOverlays' with: [ spec requires: #('DebuggableASTDebugger' 'Ghost') ]].

			"Groups"
			spec
				group: 'default' with: #('Model');
				group: 'Model' with: #('DebuggableASTInterpreter');
				group: 'Bootstrap' with: #('DebuggableASTInterpreterBootstrap');
				group: 'Debugger' with: #('DebuggableASTDebugger');
				group: 'Overlay' with: #('DebuggableASTInterpreterOverlays')
]
