# Builds SomeThing::SomeWhere::OSAdviser with some methods.  May not be the best way to do this.
module ClassBuilder
  def make_data_source_methods(os, install_method)
    make_data_source_class
    SomeThing::SomeWhere::OSAdviser.send(:define_method, 'os') { |capitalise = false| capitalise ? os.capitalize : os }
    SomeThing::SomeWhere::OSAdviser.send(:define_method, 'install_method') { install_method }
    SomeThing::SomeWhere::OSAdviser.send(:define_method, 'service_call') { @service.service_method }
  end

  def make_data_source_class
    some_where = make_data_source_module
    os_adviser = Class.new
    os_adviser.send(:define_method, :initialize) do |services|
      @service = services[:os_service]
    end
    some_where.const_set(:OSAdviser, os_adviser)
  end

  def make_data_source_module
    some_thing = Kernel.const_set(:SomeThing, Module.new)
    some_thing.const_set(:SomeWhere, Module.new)
  end

  def remove_data_source_class
    some_thing = Kernel.const_get(:SomeThing)
    some_where = some_thing.const_get(:SomeWhere)
    some_where.send(:remove_const, :OSAdviser)
  end
end
