var search_data = {"index":{"searchIndex":["fourthdimensional","aggregateroot","command","commandhandler","commandandevents","configuration","error","event","eventable","classmethods","repository","==()","apply()","apply_existing_event()","attributes()","build_repository()","call()","config()","configure()","event_bindings()","events()","events_for_aggregate()","execute_command()","execute_commands()","included()","load_aggregate()","new()","new()","new()","new()","new()","new()","on()","save()","save_command_and_events()","with_aggregate()","readme"],"longSearchIndex":["fourthdimensional","fourthdimensional::aggregateroot","fourthdimensional::command","fourthdimensional::commandhandler","fourthdimensional::commandhandler::commandandevents","fourthdimensional::configuration","fourthdimensional::error","fourthdimensional::event","fourthdimensional::eventable","fourthdimensional::eventable::classmethods","fourthdimensional::repository","fourthdimensional::commandhandler::commandandevents#==()","fourthdimensional::aggregateroot#apply()","fourthdimensional::aggregateroot#apply_existing_event()","fourthdimensional::command::attributes()","fourthdimensional::build_repository()","fourthdimensional::commandhandler#call()","fourthdimensional::config()","fourthdimensional::configure()","fourthdimensional::eventable::classmethods#event_bindings()","fourthdimensional::eventable::classmethods#events()","fourthdimensional::repository#events_for_aggregate()","fourthdimensional::execute_command()","fourthdimensional::execute_commands()","fourthdimensional::eventable::included()","fourthdimensional::repository#load_aggregate()","fourthdimensional::aggregateroot::new()","fourthdimensional::command::new()","fourthdimensional::commandhandler::new()","fourthdimensional::commandhandler::commandandevents::new()","fourthdimensional::event::new()","fourthdimensional::repository::new()","fourthdimensional::eventable::classmethods#on()","fourthdimensional::commandhandler#save()","fourthdimensional::repository#save_command_and_events()","fourthdimensional::commandhandler#with_aggregate()",""],"info":[["FourthDimensional","","classes/FourthDimensional.html","",""],["FourthDimensional::AggregateRoot","","classes/FourthDimensional/AggregateRoot.html","","<p>FourthDimensional::AggregateRoot\n<p>An aggregate root is an object whose entire state is built by applying …\n"],["FourthDimensional::Command","","classes/FourthDimensional/Command.html","","<p>FourthDimensional::Command\n<p>Commands are the input to create events. They provide an early validation step …\n"],["FourthDimensional::CommandHandler","","classes/FourthDimensional/CommandHandler.html","","<p>FourthDimensional::CommandHandler\n<p>Command handlers have bindings that wrap a Command to load an aggregate …\n"],["FourthDimensional::CommandHandler::CommandAndEvents","","classes/FourthDimensional/CommandHandler/CommandAndEvents.html","",""],["FourthDimensional::Configuration","","classes/FourthDimensional/Configuration.html","","<p>FourthDimensional::Configuration\n\n<pre><code>FourthDimensional.configure do |config|\n  config.command_handlers = [...] ...\n</code></pre>\n"],["FourthDimensional::Error","","classes/FourthDimensional/Error.html","",""],["FourthDimensional::Event","","classes/FourthDimensional/Event.html","","<p>FourthDimensional::Event\n<p>Events act as a log primarily focused around an aggregate. When persisted it …\n"],["FourthDimensional::Eventable","","classes/FourthDimensional/Eventable.html","","<p>Eventable\n<p>Provides an api for registering event bindings.\n\n<pre><code>class CantHandleTheTruth\n  include FourthDimensional::Eventable ...\n</code></pre>\n"],["FourthDimensional::Eventable::ClassMethods","","classes/FourthDimensional/Eventable/ClassMethods.html","",""],["FourthDimensional::Repository","","classes/FourthDimensional/Repository.html","","<p>FourthDimensional::Repository\n<p>Event sourcing is a good application for the repository pattern since we …\n"],["==","FourthDimensional::CommandHandler::CommandAndEvents","classes/FourthDimensional/CommandHandler/CommandAndEvents.html#method-i-3D-3D","(other)",""],["apply","FourthDimensional::AggregateRoot","classes/FourthDimensional/AggregateRoot.html#method-i-apply","(event_class, **args)","<p>Applies an event to the aggregate when a callback is bound. **<code>args</code> are merged with the <code>id</code> of the aggregate. …\n"],["apply_existing_event","FourthDimensional::AggregateRoot","classes/FourthDimensional/AggregateRoot.html#method-i-apply_existing_event","(event)","<p>Calls the event binding without persisting the event being applied. Used when loading an aggregate from …\n"],["attributes","FourthDimensional::Command","classes/FourthDimensional/Command.html#method-c-attributes","(*attributes)","<p>Defines an initializer with required keyword arguments, readonly only attributes and <code>to_h</code> to access all …\n"],["build_repository","FourthDimensional","classes/FourthDimensional.html#method-c-build_repository","()","<p>Iniitlaizes a Repository with the required dependencies.\n\n<pre><code>FourthDimensional.repository # =&gt; FourthDimensional::Repository\n</code></pre>\n"],["call","FourthDimensional::CommandHandler","classes/FourthDimensional/CommandHandler.html#method-i-call","(command)","<p>Invokes a callback for an command.\n"],["config","FourthDimensional","classes/FourthDimensional.html#method-c-config","()","<p>The singleton instance of Configuration\n"],["configure","FourthDimensional","classes/FourthDimensional.html#method-c-configure","()","<p>Yields the Configuration instance\n\n<pre><code>FourthDimensional.configure do |config|\n  config.command_handlers = ...\n</code></pre>\n"],["event_bindings","FourthDimensional::Eventable::ClassMethods","classes/FourthDimensional/Eventable/ClassMethods.html#method-i-event_bindings","()","<p>Returns a hash of event classes and the callback.\n\n<pre><code>Post.on(PostAdded, -&gt; (event) {})\nPost.on(PostDeleted, ...\n</code></pre>\n"],["events","FourthDimensional::Eventable::ClassMethods","classes/FourthDimensional/Eventable/ClassMethods.html#method-i-events","()","<p>Returns an array of class names for the bound events.\n\n<pre><code>Post.on(PostAdded, -&gt; (event) {})\nPost.on(PostDeleted, ...\n</code></pre>\n"],["events_for_aggregate","FourthDimensional::Repository","classes/FourthDimensional/Repository.html#method-i-events_for_aggregate","(aggregate_id)","<p>Delegates to +event_loader#for_aggregate+\n\n<pre><code>FourthDimensional.repository.events_for_aggregate(aggregate_id)\n</code></pre>\n"],["execute_command","FourthDimensional","classes/FourthDimensional.html#method-c-execute_command","(*commands)",""],["execute_commands","FourthDimensional","classes/FourthDimensional.html#method-c-execute_commands","(*commands)","<p>Runs a single or array of commands through all command handlers, saves commands and applied events, and …\n"],["included","FourthDimensional::Eventable","classes/FourthDimensional/Eventable.html#method-c-included","(klass)",""],["load_aggregate","FourthDimensional::Repository","classes/FourthDimensional/Repository.html#method-i-load_aggregate","(aggregate_class, aggregate_id)","<p>Loads events from <code>event_loader</code> and applies them to a new instance of <code>aggregate_class</code>\n\n<pre><code>FourthDimensional.repository.load_aggregate(PostAggregate, ...\n</code></pre>\n"],["new","FourthDimensional::AggregateRoot","classes/FourthDimensional/AggregateRoot.html#method-c-new","(id:)","<p>Initializes an aggregate with an id\n"],["new","FourthDimensional::Command","classes/FourthDimensional/Command.html#method-c-new","(aggregate_id:)",""],["new","FourthDimensional::CommandHandler","classes/FourthDimensional/CommandHandler.html#method-c-new","(repository:)",""],["new","FourthDimensional::CommandHandler::CommandAndEvents","classes/FourthDimensional/CommandHandler/CommandAndEvents.html#method-c-new","(command:, events:)",""],["new","FourthDimensional::Event","classes/FourthDimensional/Event.html#method-c-new","(aggregate_id:, data: nil, metadata: nil)","<p>Initializes an event with the required <code>aggregate_id</code> and optional <code>data</code> and <code>metadata</code>.\n\n<pre><code>event = MyEvent.new(aggregate_id: ...\n</code></pre>\n"],["new","FourthDimensional::Repository","classes/FourthDimensional/Repository.html#method-c-new","(event_loader:)",""],["on","FourthDimensional::Eventable::ClassMethods","classes/FourthDimensional/Eventable/ClassMethods.html#method-i-on","(klass, &block)","<p>Binds an event to the aggregate. Raises a <code>KeyError</code> if the event has already been bound.\n\n<pre><code>Post.on(PostAdded, ...\n</code></pre>\n"],["save","FourthDimensional::CommandHandler","classes/FourthDimensional/CommandHandler.html#method-i-save","(command, aggregate)","<p>Saves the command and aggregate&#39;s applied events\n\n<pre><code>class PostCommandHandler &lt; FourthDimensional::CommandHandler ...\n</code></pre>\n"],["save_command_and_events","FourthDimensional::Repository","classes/FourthDimensional/Repository.html#method-i-save_command_and_events","(command_and_events)","<p>Saves the command and events with the <code>event_loader</code>\n\n<pre><code>repository.save_command_and_events(FourthDimensional::CommandHandler::CommandAndEvents.new( ...\n</code></pre>\n"],["with_aggregate","FourthDimensional::CommandHandler","classes/FourthDimensional/CommandHandler.html#method-i-with_aggregate","(aggregate_class, command, &block)","<p>Yields the aggregate and saves the applied events\n"],["README","","files/README_md.html","","<p>Fourth Dimensional\n<p>Fourth Dimensional is an event sourcing library to account for the state of a\nsystem ...\n"]]}}