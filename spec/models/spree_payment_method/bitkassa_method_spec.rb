require "spec_helper"

describe Spree::PaymentMethod::BitkassaMethod do
  let(:order) do
    instance_double("Spree::Order",
                    payment_total: 1337,
                    number: "R42")
  end

  let(:payment_response) do
    instance_double("Bitkassa::PaymentResponse",
                    payment_url: "https://example.com/tx/qwerty")
  end

  describe "#initalize configures Bitkassa" do
    let(:bitkassa_config) do
      instance_double("Bitkassa::Config",
                      :secret_api_key= => nil,
                      :merchant_id= => nil)
    end

    before do
      allow(Bitkassa).to receive(:config).and_return(bitkassa_config)
    end

    it "sets the merchant_id" do
      expect(bitkassa_config).to receive(:merchant_id=).with("MERCHANTID")
      described_class.new
    end

    it "sets the secret_api_key" do
      expect(bitkassa_config).to receive(:secret_api_key=).with("SECRET")
      described_class.new
    end
  end

  describe "#initiate" do
    let(:payment_request) do
      instance_double("Bitkassa::PaymentRequest",
                      perform: payment_response)
    end

    before do
      allow(Bitkassa::PaymentRequest).to receive(:new)
        .and_return(payment_request)
    end

    it "initiates Bitkassa::PaymentRequest with currency" do
      expected = { currency: "EUR" }
      expect(Bitkassa::PaymentRequest).to receive(:new)
        .with(hash_including(expected))
      subject.initiate(order)
    end

    it "performs a new request on the PaymentRequest" do
      expect(payment_request).to receive(:perform).and_return(payment_response)
      subject.initiate(order)
    end
  end

  describe "#payment_url" do
    it "returns the payment_url from the PaymentResponse" do
      subject.instance_variable_set(:@response, payment_response)
      expect(subject.payment_url).to eq "https://example.com/tx/qwerty"
    end

    it "raises an exception when payment_response is not set" do
      subject.instance_variable_set(:@response, nil)
      expect { subject.payment_url }.to raise_exception(
        Spree::PaymentMethod::BitkassaMethod::PaymentNotInitiated
      )
    end
  end

  describe "#source_required" do
    it { expect(subject.source_required?).to eq false }
  end
end
