//
//  Generator+Expression.swift
//  Format
//
//  Created by Angel Garcia on 14/07/2017.
//

import AST

extension Generator {
    
    open func generate(_ expression: Expression) -> String {        
        switch expression {
        case let expr as AssignmentOperatorExpression:
            return generate(expr)
        case let expr as BinaryOperatorExpression:
            return generate(expr)
        case let expr as ClosureExpression:
            return generate(expr)
        case let expr as ExplicitMemberExpression:
            return generate(expr)
        case let expr as ForcedValueExpression:
            return generate(expr)
        case let expr as FunctionCallExpression:
            return generate(expr)
        case let expr as IdentifierExpression:
            return generate(expr)
        case let expr as ImplicitMemberExpression:
            return generate(expr)
        case let expr as InOutExpression:
            return generate(expr)
        case let expr as InitializerExpression:
            return generate(expr)
        case let expr as KeyPathStringExpression:
            return generate(expr)
        case let expr as LiteralExpression:
            return generate(expr)
        case let expr as OptionalChainingExpression:
            return generate(expr)
        case let expr as ParenthesizedExpression:
            return generate(expr)
        case let expr as PostfixOperatorExpression:
            return generate(expr)
        case let expr as PostfixSelfExpression:
            return generate(expr)
        case let expr as PrefixOperatorExpression:
            return generate(expr)
        case let expr as SelectorExpression:
            return generate(expr)
        case let expr as SelfExpression:
            return generate(expr)
        case let expr as SubscriptExpression:
            return generate(expr)
        case let expr as SuperclassExpression:
            return generate(expr)
        case let expr as TernaryConditionalOperatorExpression:
            return generate(expr)
        case let expr as TryOperatorExpression:
            return generate(expr)
        case let expr as TupleExpression:
            return generate(expr)
        case let expr as TypeCastingOperatorExpression:
            return generate(expr)
        case let expr as WildcardExpression:
            return generate(expr)
        default:
            return expression.textDescription
        }
    }
    
    open func generate(_ expression: AssignmentOperatorExpression) -> String {
        return "\(generate(expression.leftExpression)) = \(generate(expression.rightExpression))"
    }
    
    open func generate(_ expression: BinaryOperatorExpression) -> String {
        return "\(generate(expression.leftExpression)) \(expression.binaryOperator) \(generate(expression.rightExpression))"
    }
    
    open func generate(_ expression: ClosureExpression) -> String {
        var signatureText = ""
        var stmtsText = ""
        
        if let signature = expression.signature {
            signatureText = " \(generate(signature)) in"
            if expression.statements == nil {
                stmtsText = " "
            }
        }
        
        if let stmts = expression.statements {
            if expression.signature == nil && stmts.count == 1 {
                stmtsText = " \(generate(stmts)) "
            } else {
                stmtsText = "\n\(generate(stmts))\n"
            }
        }
        
        return "{\(signatureText)\(stmtsText)}"
    }
    
    open func generate(_ expression: ClosureExpression.Signature.CaptureItem.Specifier) -> String {
        return expression.rawValue
    }
    
    open func generate(_ expression: ClosureExpression.Signature.CaptureItem) -> String {
        let exprText = generate(expression.expression)
        guard let specifier = expression.specifier else {
            return exprText
        }
        return "\(generate(specifier)) \(exprText)"
    }
    
    open func generate(_ expression: ClosureExpression.Signature.ParameterClause.Parameter) -> String {
        var paramText = expression.name
        if let typeAnnotation = expression.typeAnnotation {
            paramText += generate(typeAnnotation)
            if expression.isVarargs {
                paramText += "..."
            }
        }
        return paramText
    }
    
    open func generate(_ expression: ClosureExpression.Signature.ParameterClause) -> String {
        switch expression {
        case .parameterList(let params):
            return "(\(params.map(generate).joined(separator: ", ")))"
        case .identifierList(let idList):
            return idList.textDescription
        }
    }
    
    open func generate(_ expression: ClosureExpression.Signature) -> String {
        var signatureText = [String]()
        if let captureList = expression.captureList {
            signatureText.append("[\(captureList.map(generate).joined(separator: ", "))]")
        }
        if let parameterClause = expression.parameterClause {
            signatureText.append(generate(parameterClause))
        }
        if expression.canThrow {
            signatureText.append("throws")
        }
        if let funcResult = expression.functionResult {
            signatureText.append(generate(funcResult))
        }
        return signatureText.joined(separator: " ")
    }
    
    open func generate(_ expression: ExplicitMemberExpression) -> String {
        switch expression.kind {
        case let .tuple(postfixExpr, index):
            return "\(generate(postfixExpr)).\(index)"
        case let .namedType(postfixExpr, identifier):
            return "\(generate(postfixExpr)).\(identifier)"
        case let .generic(postfixExpr, identifier, genericArgumentClause):
            return "\(generate(postfixExpr)).\(identifier)" +
            "\(generate(genericArgumentClause))"
        case let .argument(postfixExpr, identifier, argumentNames):
            var textDesc = "\(generate(postfixExpr)).\(identifier)"
            if !argumentNames.isEmpty {
                let argumentNamesDesc = argumentNames.map({ "\($0):" }).joined()
                textDesc += "(\(argumentNamesDesc))"
            }
            return textDesc
        }
    }
    
    open func generate(_ expression: ForcedValueExpression) -> String {
        return "\(generate(expression.postfixExpression))!"
    }
    
    open func generate(_ expression: FunctionCallExpression) -> String {
        var parameterText = ""
        if let argumentClause = expression.argumentClause {
            let argumentsText = argumentClause.map(generate).joined(separator: ", ")
            parameterText = "(\(argumentsText))"
        }
        var trailingText = ""
        if let trailingClosure = expression.trailingClosure {
            trailingText = " \(generate(trailingClosure))"
        }
        return "\(generate(expression.postfixExpression))\(parameterText)\(trailingText)"
    }
    
    open func generate(_ expression: FunctionCallExpression.Argument) -> String {
        switch expression {
        case .expression(let expr):
            return generate(expr)
        case let .namedExpression(identifier, expr):
            return "\(identifier): \(generate(expr))"
        case .memoryReference(let expr):
            return "&\(generate(expr))"
        case let .namedMemoryReference(name, expr):
            return "\(name): &\(generate(expr))"
        case .operator(let op):
            return op
        case let .namedOperator(identifier, op):
            return "\(identifier): \(op)"
        }
    }
    
    open func generate(_ expression: IdentifierExpression) -> String {
        switch expression.kind {
        case let .identifier(id, generic):
            return "\(id)\(generic.map(generate) ?? "")"
        case let .implicitParameterName(i, generic):
            return "$\(i)\(generic.map(generate) ?? "")"
        }
    }
    
    open func generate(_ expression: ImplicitMemberExpression) -> String {
        return ".\(expression.identifier)"
    }
    
    open func generate(_ expression: InOutExpression) -> String {
        return "&\(expression.identifier)"
    }
    
    open func generate(_ expression: InitializerExpression) -> String {
        var textDesc = "\(generate(expression.postfixExpression)).init"
        if !expression.argumentNames.isEmpty {
            let argumentNamesDesc = expression.argumentNames.map({ "\($0):" }).joined()
            textDesc += "(\(argumentNamesDesc))"
        }
        return textDesc
    }
    
    open func generate(_ expression: KeyPathStringExpression) -> String {
        return "#keyPath(\(generate(expression.expression)))"
    }
    
    open func generate(_ expression: LiteralExpression) -> String {
        switch expression.kind {
        case .nil:
            return "nil"
        case .boolean(let bool):
            return bool ? "true" : "false"
        case let .integer(_, rawText):
            return rawText
        case let .floatingPoint(_, rawText):
            return rawText
        case let .staticString(_, rawText):
            return rawText
        case let .interpolatedString(_, rawText):
            return rawText
        case .array(let exprs):
            return "[\(generate(exprs))]"
        case .dictionary(let entries):
            if entries.isEmpty {
                return "[:]"
            }
            let dictText = entries.map(generate).joined(separator: ", ")
            return "[\(dictText)]"
        }
    }
    
    open func generate(_ expression: OptionalChainingExpression) -> String {
        return "\(generate(expression.postfixExpression))?"
    }
    
    open func generate(_ expression: ParenthesizedExpression) -> String {
        return "(\(generate(expression.expression)))"
    }
    
    open func generate(_ expression: PostfixOperatorExpression) -> String {
        return "\(generate(expression.postfixExpression))\(expression.postfixOperator)"
    }
    
    open func generate(_ expression: PostfixSelfExpression) -> String {
        return "\(generate(expression.postfixExpression)).self"
    }
    
    open func generate(_ expression: PrefixOperatorExpression) -> String {
        return "\(expression.prefixOperator)\(generate(expression.postfixExpression))"
    }
    
    open func generate(_ expression: SelectorExpression) -> String {
        switch expression.kind {
        case .selector(let expr):
            return "#selector(\(generate(expr)))"
        case .getter(let expr):
            return "#selector(getter: \(generate(expr)))"
        case .setter(let expr):
            return "#selector(setter: \(generate(expr)))"
        case let .selfMember(identifier, argumentNames):
            var textDesc = identifier
            if !argumentNames.isEmpty {
                let argumentNamesDesc = argumentNames.map({ "\($0):" }).joined()
                textDesc += "(\(argumentNamesDesc))"
            }
            return "#selector(\(textDesc))"
        }
    }
    
    open func generate(_ expression: SelfExpression) -> String {
        switch expression.kind {
        case .self:
            return "self"
        case .method(let name):
            return "self.\(name)"
        case .subscript(let exprs):
            return "self[\(generate(exprs))]"
        case .initializer:
            return "self.init"
        }
    }
    
    open func generate(_ expression: SubscriptExpression) -> String {
        return "\(generate(expression.postfixExpression))[\(generate(expression.expressionList))]"
    }
    
    open func generate(_ expression: SuperclassExpression) -> String {
        switch expression.kind {
        case .method(let name):
            return "super.\(name)"
        case .subscript(let exprs):
            return "super[\(generate(exprs))]"
        case .initializer:
            return "super.init"
        }
    }
    
    open func generate(_ expression: TernaryConditionalOperatorExpression) -> String {
        return "\(generate(expression.conditionExpression)) ? \(generate(expression.trueExpression)) : \(generate(expression.falseExpression))"
    }
    
    open func generate(_ expression: TryOperatorExpression) -> String {
        let tryText: String
        let exprText: String
        switch expression.kind {
        case .try(let expr):
            tryText = "try"
            exprText = generate(expr)
        case .forced(let expr):
            tryText = "try!"
            exprText = generate(expr)
        case .optional(let expr):
            tryText = "try?"
            exprText = generate(expr)
        }
        return "\(tryText) \(exprText)"
    }
    
    open func generate(_ expression: TupleExpression) -> String {
        if expression.elementList.isEmpty {
            return "()"
        }
        
        let listText: [String] = expression.elementList.map { element in
            var idText = ""
            if let id = element.identifier {
                idText = "\(id): "
            }
            return "\(idText)\(generate(element.expression))"
        }
        return "(\(listText.joined(separator: ", ")))"
    }
    
    open func generate(_ expression: TypeCastingOperatorExpression) -> String {
        let exprText: String
        let operatorText: String
        let typeText: String
        switch expression.kind {
        case let .check(expr, type):
            exprText = generate(expr)
            operatorText = "is"
            typeText = generate(type)
        case let .cast(expr, type):
            exprText = generate(expr)
            operatorText = "as"
            typeText = generate(type)
        case let .conditionalCast(expr, type):
            exprText = generate(expr)
            operatorText = "as?"
            typeText = generate(type)
        case let .forcedCast(expr, type):
            exprText = generate(expr)
            operatorText = "as!"
            typeText = generate(type)
        }
        return "\(exprText) \(operatorText) \(typeText)"
    }
    
    open func generate(_ expression: WildcardExpression) -> String {
        return "_"
    }
    
    
    // MARK: Utils
    
    open func generate(_ expression: DictionaryEntry) -> String {
        return "\(generate(expression.key)): \(generate(expression.value))"
    }
    
}