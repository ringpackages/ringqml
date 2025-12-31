
class ringQMLObject
	pObject=''
	aAllProps = []
	func init pObj 
		if ! ispointer(pObj) return self ok
		if pObj[2] != "QObject" return pObj ok 
		pObject = pObj
		aAllProps = ref( ringqmlobjectgetallprops_now(pObject)[1] )
		for item in aAllProps
			item[1] = lower(item[1])
		next

		return self
	/*
		Name : property
		Usage : property( cname )
		Params :cname (String)
		return : qVariant (Object)
	*/
	func property(cname)
		ptmp = new qVariant
		ptmp.pObject = qobject_property(pObject ,cname ) 
		return ptmp
	func operator cOp,val

		if cOp= '[]'
			if isstring(val)
				cLastProp=val
			ok
			return self
		else
		ok
	/*
		Name : setv
		Usage : Obj[Attr].setv(Val)
		Params :Val (String|Number)
		return : l_isOk (0|1)
	*/
	func setv Val
		return set(Val)
	func set Val
		pVal = ''
		if isnumber(Val)
			pVal = new qVariantint(Val) 
		but isstring(Val)
			pVal = new qvariantstring(Val) 
		else
			raise(" Error in set method,list/object not supported ")
		ok
		l_isOk = ringqmlobjectsetpropbypath(pObject,cLastProp, getobjectpointerfromringobject(pVal))
		if l_isOk
			aAllProps[cLastProp]=Val
		ok
		return l_isOk
	/*
		Name : getValue
		Usage : Obj[Attr].getValue()
		Params :Val (String|Number)
		return : l_isOk (0|1)
	*/
	func getValue
		return aAllProps[cLastProp]
	func getv 
		return getValue()

	func _get
		return getValue()

	private 
		cLastProp=''