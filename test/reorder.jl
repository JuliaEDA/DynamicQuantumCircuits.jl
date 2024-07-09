using DynamicQuantumCircuits.Reorder

using DynamicQuantumCircuits: StateVector

@testset "Reorder operator" begin
  n = 3
  m_index = Reorder.create_bit_matrix(n)
  m_target = [
    0 0 0
    0 0 1
    0 1 0
    0 1 1
    1 0 0
    1 0 1
    1 1 0
    1 1 1
  ]
  m_target_reordered = [
    0 0 0
    0 0 1
    1 0 0
    1 0 1
    0 1 0
    0 1 1
    1 1 0
    1 1 1
  ]

  # FIXME import combine
  #state_vector = StateVector([1, 0], [2])

  indices = [1, 0, 2]
  m_index_reordered = Reorder.reorder_columns(m_index, indices)

  @testset "create_bit_matrix" begin
    @test size(m_index) == size(m_target)
    @test m_index == m_target
  end

  @testset "reorder matrix based on state_vector $indices" begin
    @test m_index_reordered == m_target_reordered
  end


end
