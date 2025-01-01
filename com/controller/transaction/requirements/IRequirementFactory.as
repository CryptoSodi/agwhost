package com.controller.transaction.requirements
{
	import com.model.prototype.IPrototype;

	public interface IRequirementFactory
	{
		function createRequirement( proto:IPrototype, klass:Class ):IRequirement;
	}
}
