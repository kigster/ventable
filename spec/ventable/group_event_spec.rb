# require 'spec_helper'
#
# describe Ventable do
#   before do
#     class TestEvent
#       include Ventable::Event
#     end
#   end
#
#   it 'configures observers with groups' do
#     notified_observer  = false
#     called_transaction = false
#     TestEvent.configure do
#       group :transaction, &->(b) {
#         b.call
#         called_transaction = true
#       }
#       notifies inside: :transaction do
#         notified_observer = true
#       end
#     end
#     TestEvent.new.publish
#     expect(notified_observer).to be true
#     expect(called_transaction).to be true
#   end
#
#   it 'should properly call a group of observers' do
#     transaction_called    = false
#     transaction_completed = false
#     transaction           = ->(observer_block) {
#       transaction_called = true
#       observer_block.call
#       transaction_completed = true
#     }
#
#     TestEvent.group :transaction, &transaction
#     observer_block_called = false
#
#     # this flag ensures that this block really runs inside
#     # the transaction group block
#     transaction_already_completed = false
#     event_inside                  = nil
#     TestEvent.notifies inside: :transaction do |event|
#       observer_block_called         = true
#       transaction_already_completed = transaction_completed
#       event_inside                  = event
#     end
#
#     expect(transaction_called).to be false
#     expect(transaction_already_completed).to be false
#     expect(observer_block_called).to be false
#
#     TestEvent.new.publish
#
#     expect(transaction_called).to be true
#     expect(observer_block_called).to be true
#     expect(transaction_called).to be true
#     expect(transaction_already_completed).to be false
#     expect(event_inside).to_not be_nil
#     expect(event_inside).to be_a(TestEvent)
#   end
# end
#
